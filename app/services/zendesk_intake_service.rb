class ZendeskIntakeService
  include ZendeskServiceHelper
  include AttachmentsHelper
  include ConsolidatedTraceHelper
  include Rails.application.routes.url_helpers

  def initialize(intake)
    @intake = intake
  end

  def logger
    Rails.logger
  end

  def instance
    @instance ||= @intake.zendesk_instance
  end

  def instance_eitc?
    instance == EitcZendeskInstance
  end

  # TODO: remove this after we backfill links
  def attach_requested_docs_link(ticket)
    if instance_eitc?
      ticket.fields = {
        EitcZendeskInstance::DOCUMENT_REQUEST_LINK => @intake.requested_docs_token_link
      }
    else
      ticket.fields = {
        UwtsaZendeskInstance::DOCUMENT_REQUEST_LINK => @intake.requested_docs_token_link
      }
    end
    ticket.save
  end

  def assign_requester
    # if the requester has been assigned, return it.
    return @intake.intake_ticket_requester_id if @intake.intake_ticket_requester_id.present?

    # if not, attempt to create a requester and return it
    if requester_id = create_intake_ticket_requester
      @intake.update(intake_ticket_requester_id: requester_id)
      return requester_id
    end

    # failing all else, that's likely noteworthy
    trace_error('ZendeskIntakeTicketJob failed to create a ticket requester',
                intake_context(@intake))
    return # ensure a nil return value
  end

  def create_intake_ticket_requester
    # returns the Zendesk ID of the created user
    contact_info = @intake.contact_info_filtered_by_preferences
    find_or_create_end_user(
      @intake.preferred_name,
      contact_info[:email],
      contact_info[:phone_number],
      exact_match: true
    )
  end

  def create_intake_ticket
    # returns the Zendesk ID of the created ticket
    raise MissingRequesterIdError if @intake.intake_ticket_requester_id.blank?
    @intake.assign_vita_partner! if @intake.vita_partner.blank?

    @intake.transaction do
      # we only want to create an initial ticket status if we are able
      # to make a zendesk ticket without errors
      ticket_id = create_ticket(
        subject: new_ticket_subject,
        requester_id: @intake.intake_ticket_requester_id,
        external_id: @intake.external_id,
        group_id: @intake.vita_partner.zendesk_group_id,
        body: new_ticket_body,
        fields: new_ticket_fields
      )
      ticket_status = @intake.ticket_statuses.create(
        intake_status: EitcZendeskInstance::INTAKE_STATUS_IN_PROGRESS,
        return_status: EitcZendeskInstance::RETURN_STATUS_UNSTARTED,
        ticket_id: ticket_id
      )
      @intake.update(intake_ticket_id: ticket_id)
      ticket_status.send_mixpanel_event
      ticket_id
    end
  end

  def new_ticket_subject
    suffix = (Rails.env.production? || Rails.env.test?) ? "" : " (Test Ticket)"
    @intake.primary_full_name + suffix
  end

  def new_ticket_body
    <<~BODY
      #{new_ticket_body_header}

      Preferred name: #{@intake.preferred_name}
      Legal first name: #{@intake.primary_first_name}
      Legal last name: #{@intake.primary_last_name}
      Phone number: #{@intake.formatted_phone_number}
      Email: #{@intake.email_address}
      State of residence: #{@intake.state_of_residence_name}
      Client answered questions for the #{@intake.most_recent_filing_year} tax year.
      #{additional_ticket_messages}
      #{contact_preferences}
      #{new_ticket_body_footer}
    BODY
  end

  def new_ticket_fields
    notification_opt_ins = [
      ("sms_opt_in" if @intake.sms_notification_opt_in_yes?),
      ("email_opt_in" if @intake.email_notification_opt_in_yes?),
    ].compact

    if instance_eitc?
      {
        EitcZendeskInstance::INTAKE_SITE => "online_intake",
        EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_IN_PROGRESS,
        EitcZendeskInstance::STATE => @intake.state_of_residence,
        EitcZendeskInstance::FILING_YEARS => @intake.filing_years,
        EitcZendeskInstance::COMMUNICATION_PREFERENCES => notification_opt_ins,
        EitcZendeskInstance::DOCUMENT_REQUEST_LINK => @intake.requested_docs_token_link,
        EitcZendeskInstance::INTAKE_SOURCE => @intake.source,
      }
    else
      {
        UwtsaZendeskInstance::INTAKE_SITE => "online_intake",
        UwtsaZendeskInstance::INTAKE_STATUS => UwtsaZendeskInstance::INTAKE_STATUS_IN_PROGRESS,
        UwtsaZendeskInstance::STATE => @intake.state_of_residence,
        UwtsaZendeskInstance::FILING_YEARS => @intake.filing_years,
        UwtsaZendeskInstance::COMMUNICATION_PREFERENCES => notification_opt_ins,
        UwtsaZendeskInstance::DOCUMENT_REQUEST_LINK => @intake.requested_docs_token_link,
      }
    end
  end

  def send_preliminary_intake_and_consent_pdfs
    comment_body = <<~BODY
      Preliminary 13614-C questions answered.

      Primary filer (and spouse, if applicable) consent form attached.
    BODY

    # if there's no intake_ticket_id, this shouldn't be performed,
    # and that should be noted.
    output = append_multiple_files_to_ticket(
      ticket_id: @intake.intake_ticket_id,
      file_list: [
        {file: @intake.pdf, filename: intake_pdf_filename},
        {file: @intake.consent_pdf, filename: consent_pdf_filename}
      ],
      comment: comment_body,
      fields: intake_pdf_fields
    )

    raise CouldNotSendIntakePdfError unless output == true
    output
  end

  def send_final_intake_pdf
    comment_body = <<~BODY
      Online intake form submitted and ready for review. The taxpayer was notified that their information has been submitted. (automated_notification_submit_confirmation)

      Client's provided interview preferences: #{@intake.interview_timing_preference}

      Additional information from Client: #{@intake.final_info}
    BODY

    output = append_file_to_ticket(
      ticket_id: @intake.intake_ticket_id,
      filename: intake_pdf_filename(final: true),
      file: @intake.pdf,
      comment: comment_body,
      fields: intake_pdf_final_fields
    )

    raise CouldNotSendCompletedIntakePdfError unless output == true
    output
  end

  def send_intake_pdf_with_spouse
    comment_body = <<~BODY
      Updated 13614-c from online intake - added spouse signature and contact
    BODY

    output = append_file_to_ticket(
      ticket_id: @intake.intake_ticket_id,
      filename: intake_pdf_filename,
      file: @intake.pdf,
      comment: comment_body,
    )

    raise CouldNotSendCompletedIntakePdfError unless output == true
    output
  end

  def send_consent_pdf_with_spouse
    output = append_file_to_ticket(
      ticket_id: @intake.intake_ticket_id,
      filename: consent_pdf_filename,
      file: @intake.consent_pdf,
      comment: <<~COMMENT,
        Updated signed consent form with spouse signature
      COMMENT
    )

    raise CouldNotSendConsentPdfError unless output == true
    output
  end

  def send_bank_details_png
    return true unless @intake.include_bank_details?

    output = append_file_to_ticket(
      ticket_id: @intake.intake_ticket_id,
      filename: bank_details_png_filename,
      file: @intake.bank_details_png,
      comment: <<~COMMENT,
        Bank account information for direct deposit and/or payment
      COMMENT
    )

    raise CouldNotSendBankDetailsError unless output == true
    output
  end

  def send_all_docs
    download_attachments_to_tmp(@intake.documents.map(&:upload)) do |file_list|

      output = append_multiple_files_to_ticket(
        ticket_id: @intake.intake_ticket_id,
        file_list: file_list,
        comment: "Documents:\n" + @intake.documents.map {|d| "* #{d.upload.filename} (#{d.document_type})\n"}.join,
      )

      raise CouldNotSendDocumentError unless output
      output
    end
  end

  def contact_preferences
    return no_notifications unless @intake.opted_into_notifications?
    text = "Prefers notifications by:\n"
    text << "    • Text message\n" if @intake.sms_notification_opt_in_yes?
    text << "    • Email\n" if @intake.email_notification_opt_in_yes?
    text
  end

  private

  def additional_ticket_messages
    messages = ""
    messages << "Client has already filed for 2019\n" if @intake.already_filed_yes?
    messages << "Client is filing for Economic Impact Payment support\n" if @intake.filing_for_stimulus_yes?
    messages
  end

  def primary_name_for_filename
    @intake.primary_full_name.split(" ").map(&:capitalize).join
  end

  def additional_info_doc_filename
    "#{primary_name_for_filename}_identity_info.png"
  end

  def consent_pdf_filename
    "Consent_#{primary_name_for_filename}.pdf"
  end

  def bank_details_png_filename
    "Bank_details_#{primary_name_for_filename}.png"
  end

  def intake_pdf_filename(final: false)
    "#{"Final" if final}13614c_#{primary_name_for_filename}.pdf"
  end

  def no_notifications
    "Did not want email or text message notifications.\n"
  end

  def intake_pdf_fields
    if instance_eitc?
      {
        EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS,
        EitcZendeskInstance::DOCUMENT_REQUEST_LINK => @intake.requested_docs_token_link,
      }
    else
      {
        UwtsaZendeskInstance::INTAKE_STATUS => UwtsaZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS,
        UwtsaZendeskInstance::DOCUMENT_REQUEST_LINK => @intake.requested_docs_token_link,
      }
    end
  end

  def intake_pdf_final_fields
    if instance_eitc?
      {
        EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_READY_FOR_REVIEW,
        EitcZendeskInstance::DOCUMENT_REQUEST_LINK => @intake.requested_docs_token_link,
      }
    else
      {
        UwtsaZendeskInstance::INTAKE_STATUS => UwtsaZendeskInstance::INTAKE_STATUS_READY_FOR_REVIEW,
        UwtsaZendeskInstance::DOCUMENT_REQUEST_LINK => @intake.requested_docs_token_link,
      }
    end
  end

  def new_ticket_body_header
    "New Online Intake Started"
  end

  def new_ticket_body_footer
    <<~FOOTER.strip
      This filer has consented to this VITA pilot
    FOOTER
  end

  class CouldNotSendIntakePdfError < ZendeskServiceError;
  end
  class CouldNotSendCompletedIntakePdfError < ZendeskServiceError;
  end
  class CouldNotSendConsentPdfError < ZendeskServiceError;
  end
  class CouldNotSendBankDetailsError < ZendeskServiceError;
  end
  class CouldNotSendDocumentError < ZendeskServiceError;
  end
end
