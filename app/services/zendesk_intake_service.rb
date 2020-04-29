class ZendeskIntakeService
  include ZendeskServiceHelper
  include AttachmentsHelper
  include Rails.application.routes.url_helpers

  def initialize(intake)
    @intake = intake
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

    create_ticket(
      subject: new_ticket_subject,
      requester_id: @intake.intake_ticket_requester_id,
      external_id: @intake.external_id,
      group_id: @intake.get_or_create_zendesk_group_id,
      body: new_ticket_body,
      fields: new_ticket_fields
    )
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

  def primary_name_for_filename
    @intake.primary_full_name.split(" ").map(&:capitalize).join
  end

  def additional_info_doc_filename
    "#{primary_name_for_filename}_identity_info.png"
  end

  def consent_pdf_filename
    "Consent_#{primary_name_for_filename}.pdf"
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
  class CouldNotSendDocumentError < ZendeskServiceError;
  end
  class CouldNotSendAdditionalInfoDocError < ZendeskServiceError;
  end
end
