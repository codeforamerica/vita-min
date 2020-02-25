class ZendeskIntakeService
  include ZendeskServiceHelper
  include ActiveStorage::Downloading

  ONLINE_INTAKE_THC_UWBA_STATES = %w(co nm ne ks ca ak fl nv sd tx wa wy).freeze
  ONLINE_INTAKE_GWISR_STATES = %w(ga al).freeze
  EITC_INSTANCE_STATES = (ONLINE_INTAKE_THC_UWBA_STATES + ONLINE_INTAKE_GWISR_STATES).freeze

  def initialize(intake)
    @intake = intake
  end

  def state
    @intake.state
  end

  def instance
    @instance ||= instance_for_state
  end

  def instance_for_state
    if (EITC_INSTANCE_STATES.include? state) || state.nil?
      EitcZendeskInstance
    else
      UwtsaZendeskInstance
    end
  end

  def instance_eitc?
    instance == EitcZendeskInstance
  end

  def create_intake_ticket_requester
    # returns the Zendesk ID of the created user
    contact_info = @intake.primary_user.contact_info_filtered_by_preferences
    find_or_create_end_user(
      @intake.primary_user.full_name,
      contact_info[:email],
      contact_info[:phone_number],
      exact_match: true
    )
  end

  def create_intake_ticket
    # returns the Zendesk ID of the created ticket
    raise MissingRequesterIdError if @intake.intake_ticket_requester_id.blank?

    create_ticket(
      subject: @intake.primary_user.full_name,
      requester_id: @intake.intake_ticket_requester_id,
      group_id: new_ticket_group_id,
      body: new_ticket_body,
      fields: new_ticket_fields
    )
  end

  def new_ticket_group_id
    if ONLINE_INTAKE_THC_UWBA_STATES.include? @intake.state
      EitcZendeskInstance::ONLINE_INTAKE_THC_UWBA
    elsif ONLINE_INTAKE_GWISR_STATES.include? @intake.state
      EitcZendeskInstance::ONLINE_INTAKE_GWISR
    else
      # we do not yet have group ids for UWTSA Zendesk instance
      nil
    end
  end

  def new_ticket_body
    <<~BODY
      #{new_ticket_body_header}

      Name: #{@intake.primary_user.full_name}
      Phone number: #{@intake.primary_user.formatted_phone_number}
      Email: #{@intake.primary_user.email}
      State (based on mailing address): #{@intake.state_name}

      #{contact_preferences}
      #{new_ticket_body_footer}
    BODY
  end

  def new_ticket_fields
    if instance_eitc?
      {
        EitcZendeskInstance::INTAKE_SITE => "online_intake",
        EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_IN_PROGRESS,
      }
    else
      # We do not yet have field IDs for UWTSA Zendesk instance
      {}
    end
  end

  def send_intake_pdf
    output = append_file_to_ticket(
      ticket_id: @intake.intake_ticket_id,
      filename: intake_pdf_filename,
      file: @intake.pdf,
      comment: "New 13614-C Complete",
      fields: intake_pdf_fields
    )

    raise CouldNotSendIntakePdfError unless output == true
    output
  end

  def send_final_intake_pdf
    output = append_file_to_ticket(
      ticket_id: @intake.intake_ticket_id,
      filename: intake_pdf_filename(final: true),
      file: @intake.pdf,
      comment: <<~COMMENT,
        Online intake form submitted and ready for review. The taxpayer was notified that their information has been submitted. (automated_notification_submit_confirmation)"

        Client's provided interview preferences: #{@intake.interview_timing_preference}

        Additional information from Client: #{@intake.final_info}
      COMMENT
      fields: intake_pdf_final_fields
    )

    raise CouldNotSendCompletedIntakePdfError unless output == true
    output
  end

  def send_consent_pdf
    output = append_file_to_ticket(
      ticket_id: @intake.intake_ticket_id,
      filename: consent_pdf_filename,
      file: @intake.consent_pdf,
      comment: <<~COMMENT,
        Signed consent form
      COMMENT
    )

    raise CouldNotSendConsentPdfError unless output == true
    output
  end

  def send_all_docs
    file_list = @intake.documents.map do |document|
      @document_blob = document.upload
      tmpfile = Tempfile.open(["ZendeskIntakeService", blob.filename.extension_with_delimiter], Dir.tmpdir)
      download_blob_to(tmpfile)

      { file: tmpfile, filename: document.upload.filename.to_s }
    end

    output = append_multiple_files_to_ticket(
      ticket_id: @intake.intake_ticket_id,
      file_list: file_list,
      comment: "Documents:\n" + @intake.documents.map { |d| "* #{d.upload.filename} (#{d.document_type})\n" }.join,
    )

    raise CouldNotSendDocumentError unless output
    output
  ensure
    file_list.each { |entry| entry[:file].close! }
  end

  def send_additional_info_document
    output = append_file_to_ticket(
      ticket_id: @intake.intake_ticket_id,
      filename: additional_info_doc_filename,
      file: @intake.additional_info_png,
      comment: "Identity Info Document contains name and ssn",
    )

    raise CouldNotSendIntakePdfError unless output == true
    output
  end

  def contact_preferences
    return no_notifications unless @intake.primary_user.opted_into_notifications?
    text = "Prefers notifications by:\n"
    text << "    • Text message\n" if @intake.primary_user.sms_notification_opt_in_yes?
    text << "    • Email\n" if @intake.primary_user.email_notification_opt_in_yes?
    text
  end

  private

  def additional_info_doc_filename
    "#{@intake.primary_user.full_name.split(" ").collect(&:capitalize).join}_identity_info.png"
  end

  def consent_pdf_filename
    "#{@intake.primary_user.full_name.split(" ").collect(&:capitalize).join}_Consent.pdf"
  end

  def intake_pdf_filename(final: false)
    "#{"Final_" if final}#{@intake.primary_user.full_name.split(" ").collect(&:capitalize).join}_13614c.pdf"
  end

  def blob
    @document_blob
  end

  def no_notifications
    "Did not want email or text message notifications.\n"
  end

  def intake_pdf_fields
    if instance_eitc?
      {
        EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS,
      }
    else
      # We do not yet have field IDs for UWTSA Zendesk instance
      {}
    end
  end

  def intake_pdf_final_fields
    if instance_eitc?
      {
        EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_READY_FOR_REVIEW,
      }
    else
      # We do not yet have field IDs for UWTSA Zendesk instance
      {}
    end
  end

  def new_ticket_body_header
    "New Online Intake Started"
  end

  def new_ticket_body_footer
    <<~FOOTER.strip
      This filer has:
          • Verified their identity through ID.me
          • Consented to this VITA pilot
    FOOTER
  end

  class CouldNotSendIntakePdfError < ZendeskServiceError; end
  class CouldNotSendCompletedIntakePdfError < ZendeskServiceError; end
  class CouldNotSendConsentPdfError < ZendeskServiceError; end
  class CouldNotSendDocumentError < ZendeskServiceError; end
end