class ZendeskIntakeService
  include ZendeskServiceHelper
  include ActiveStorage::Downloading
  include Rails.application.routes.url_helpers

  ONLINE_INTAKE_THC_STATES = %w(co sd tx wy ks nm ne).freeze
  ONLINE_INTAKE_UWBA_STATES = %w(ca ak fl nv).freeze
  ONLINE_INTAKE_GWISR_STATES = %w(ga al).freeze
  ONLINE_INTAKE_UW_KING_COUNTY_STATES = %w(wa).freeze
  ONLINE_INTAKE_WORKING_FAMILIES_STATES = %w(pa).freeze
  ONLINE_INTAKE_IA_SC_STATES = %w(sc).freeze
  ONLINE_INTAKE_IA_AL_STATES = %w(tn).freeze
  EITC_INSTANCE_STATES = (
    ONLINE_INTAKE_THC_STATES +
      ONLINE_INTAKE_UWBA_STATES +
      ONLINE_INTAKE_GWISR_STATES +
      ONLINE_INTAKE_UW_KING_COUNTY_STATES +
      ONLINE_INTAKE_WORKING_FAMILIES_STATES +
      ONLINE_INTAKE_IA_SC_STATES +
      ONLINE_INTAKE_IA_AL_STATES
  ).freeze

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
      external_id: @intake.external_id,
      group_id: new_ticket_group_id,
      body: new_ticket_body,
      fields: new_ticket_fields
    )
  end

  # TODO: remove this after we backfill filing years
  def update_filing_years
    return unless @intake.intake_ticket_id.present?
    ticket = get_ticket(ticket_id: @intake.intake_ticket_id)
    return unless ticket

    if instance_eitc?
      existing_value = ticket.fields.find { |field| field["id"].to_s == EitcZendeskInstance::FILING_YEARS }.value
      ticket.fields = { EitcZendeskInstance::FILING_YEARS => ["2019"] } if existing_value.nil?
    else
      existing_value = ticket.fields.find { |field| field["id"].to_s == UwtsaZendeskInstance::FILING_YEARS }.value
      ticket.fields = { UwtsaZendeskInstance::FILING_YEARS => ["2019"] } if existing_value.nil?
    end
    ticket.save
  end

  def new_ticket_group_id
    if @intake.source.present?
      group_by_source
    else
      group_by_state
    end
  end

  def group_by_source
    source = @intake.source.downcase
    if source.start_with?("uwkc")
      EitcZendeskInstance::ONLINE_INTAKE_UW_KING_COUNTY
    elsif source.start_with?("uwvp")
      EitcZendeskInstance::ONLINE_INTAKE_UW_VIRGINIA
    elsif source.start_with?("cwf")
      EitcZendeskInstance::ONLINE_INTAKE_WORKING_FAMILIES
    elsif source.start_with?("ia")
      EitcZendeskInstance::ONLINE_INTAKE_IA_AL
    elsif source.start_with?("goodwillsr")
      EitcZendeskInstance::ONLINE_INTAKE_GWISR
    elsif source.start_with?("fc")
      EitcZendeskInstance::ONLINE_INTAKE_FC
    elsif source.start_with?("uwco")
      EitcZendeskInstance::ONLINE_INTAKE_UW_CENTRAL_OHIO
    end
  end

  def group_by_state
    if @intake.state == "wa"
      EitcZendeskInstance::ONLINE_INTAKE_UW_KING_COUNTY
    elsif @intake.state == "pa"
      EitcZendeskInstance::ONLINE_INTAKE_WORKING_FAMILIES
    elsif @intake.state == "sc"
      EitcZendeskInstance::ONLINE_INTAKE_IA_SC
    elsif @intake.state == "tn"
      EitcZendeskInstance::ONLINE_INTAKE_IA_AL
    elsif ONLINE_INTAKE_THC_STATES.include? @intake.state
      EitcZendeskInstance::ONLINE_INTAKE_THC
    elsif ONLINE_INTAKE_UWBA_STATES.include? @intake.state
      EitcZendeskInstance::ONLINE_INTAKE_UWBA
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
    notification_opt_ins = [
      ("sms_opt_in" if @intake.primary_user.sms_notification_opt_in_yes?),
      ("email_opt_in" if @intake.primary_user.email_notification_opt_in_yes?),
    ].compact

    if instance_eitc?
      {
        EitcZendeskInstance::INTAKE_SITE => "online_intake",
        EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_IN_PROGRESS,
        EitcZendeskInstance::STATE => @intake.state,
        EitcZendeskInstance::FILING_YEARS => @intake.filing_years,
        EitcZendeskInstance::COMMUNICATION_PREFERENCES => notification_opt_ins,
      }
    else
      {
        UwtsaZendeskInstance::INTAKE_SITE => "online_intake",
        UwtsaZendeskInstance::INTAKE_STATUS => UwtsaZendeskInstance::INTAKE_STATUS_IN_PROGRESS,
        UwtsaZendeskInstance::STATE => @intake.state,
        UwtsaZendeskInstance::FILING_YEARS => @intake.filing_years,
        UwtsaZendeskInstance::COMMUNICATION_PREFERENCES => notification_opt_ins,
      }
    end
  end

  def send_intake_pdf
    comment_body = "New 13614-C questions answered."
    if @intake.missing_spouse_auth?
      comment_body += <<~BODY


        ⚠️ Missing required verification for spouse.
        The following link can be sent to the spouse to get their consent and information:  
          #{verify_spouse_url(token: @intake.get_or_create_spouse_auth_token)}
      BODY
    end

    output = append_file_to_ticket(
      ticket_id: @intake.intake_ticket_id,
      filename: intake_pdf_filename,
      file: @intake.pdf,
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

    if @intake.missing_spouse_auth?
      comment_body += <<~ALERT
        
        ⚠️ Missing required verification for spouse.
        The following link can be sent to the spouse to get their consent and information:  
          #{verify_spouse_url(token: @intake.get_or_create_spouse_auth_token)}
      ALERT
    end

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

    raise CouldNotSendAdditionalInfoDocError unless output == true
    output
  end

  def send_additional_info_document_with_spouse
    output = append_file_to_ticket(
      ticket_id: @intake.intake_ticket_id,
      filename: additional_info_doc_filename,
      file: @intake.additional_info_png,
      comment: "Updated Identity Info Document with spouse - contains names and ssn's",
    )

    raise CouldNotSendAdditionalInfoDocError unless output == true
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
      {
        UwtsaZendeskInstance::INTAKE_STATUS => UwtsaZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS,
      }
    end
  end

  def intake_pdf_final_fields
    if instance_eitc?
      {
        EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_READY_FOR_REVIEW,
      }
    else
      {
        UwtsaZendeskInstance::INTAKE_STATUS => UwtsaZendeskInstance::INTAKE_STATUS_READY_FOR_REVIEW,
      }
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
  class CouldNotSendAdditionalInfoDocError < ZendeskServiceError; end
end
