module Zendesk
  class EipService
    include ZendeskServiceHelper
    include ZendeskIntakeAssignRequesterHelper
    include Rails.application.routes.url_helpers

    def initialize(intake)
      @intake = intake
    end

    def instance
      EitcZendeskInstance
    end

    def create_eip_ticket
      # All interaction with Zendesk is done within a transaction that stores the ticket ID
      # at `@intake.intake_ticket_id`. Therefore, if that field is present, we already did everything.
      return nil if @intake.intake_ticket_id.present?
      # Expect caller to use `assign_requester` to make a Zendesk requester.
      raise MissingRequesterIdError if @intake.intake_ticket_requester_id.blank?
      # Expect caller to use `assign_vita_partner`; we rely on this to compute the appropriate Zendesk group.
      raise "Missing vita_partner" if @intake.vita_partner.nil?

      tags = test_ticket_tags
      tags.push("triaged_from_stimulus") if @intake.triaged_from_stimulus?
      tags.push("211_eip_intake") if @intake.source == "211intake"

      ticket_content = {
          subject: new_ticket_subject,
          requester_id: @intake.intake_ticket_requester_id,
          external_id: @intake.external_id,
          group_id: @intake.vita_partner.zendesk_group_id,
          body: new_ticket_body,
          fields: new_ticket_fields,
          tags: test_ticket_tags,
          ticket_form_id: EitcZendeskInstance::EIP_TICKET_FORM,
      }

      @intake.transaction do
        ticket = create_ticket(**ticket_content)
        ticket_status = @intake.ticket_statuses.create(
          eip_status: EitcZendeskInstance::EIP_STATUS_STARTED,
          ticket_id: ticket.id
        )
        @intake.update(intake_ticket_id: ticket.id)
        ticket_status.send_mixpanel_event
        ticket

        update_tickets_for_other_service_options
      end
    end

    def send_completed_intake_to_zendesk
      return if @intake.completed_intake_sent_to_zendesk

      comment_body = <<~BODY
        EIP only form submitted. The taxpayer was notified that their information has been submitted.

        #{client_interview_preferences_message}
        The client's preferred language for a phone call is #{preferred_interview_language_name}

        Additional information from Client: #{@intake.final_info}

        automated_notification_submit_confirmation
      BODY

      append_comment_to_ticket(
        ticket_id: @intake.intake_ticket_id,
        comment: comment_body,
        fields: {
          EitcZendeskInstance::EIP_STATUS => EitcZendeskInstance::EIP_STATUS_SUBMITTED,
        }
      )
      @intake.update(completed_intake_sent_to_zendesk: true)
      DatadogApi.increment("zendesk.ticket.pdfs.intake.final.sent")
    end

    def send_consent_to_zendesk
      return if @intake.intake_pdf_sent_to_zendesk

      consent_comment = <<~COMMENT
        Preliminary 13614-C questions answered.

        See "Link to Client Documents" for 13614-C PDF and consent PDF(s).
      COMMENT

      append_comment_to_ticket(
        ticket_id: @intake.intake_ticket_id,
        comment: consent_comment,
        fields: {
          EitcZendeskInstance::EIP_STATUS => EitcZendeskInstance::EIP_STATUS_ID_UPLOAD,
        }
      )
      @intake.update(intake_pdf_sent_to_zendesk: true)
      DatadogApi.increment("zendesk.ticket.pdfs.intake_and_consent.preliminary.sent")
    end

    private

    def update_tickets_for_other_service_options
      diy_intake_ticket_ids = DiyIntake.where.not(email_address: nil).where.not(ticket_id: nil)
                                       .where(email_address: @intake.email_address)
                                       .pluck(:ticket_id)
      full_service_intake_ticket_ids = Intake.where.not(email_address: nil).where.not(intake_ticket_id: nil)
                                             .where(email_address: @intake.email_address, eip_only: [nil, false])
                                             .pluck(:intake_ticket_id)
      (diy_intake_ticket_ids + full_service_intake_ticket_ids).each do |ticket_id|
        append_comment_to_ticket(
          ticket_id: ticket_id,
          comment: "This client has a GetYourRefund EIP ticket: #{ticket_url(@intake.intake_ticket_id)}",
          skip_if_closed: true,
        )
      end
    end

    def new_ticket_subject
      test_ticket_suffix = (Rails.env.production? || Rails.env.test?) ? "" : " (Test Ticket)"
      @intake.primary_full_name + " EIP" + test_ticket_suffix
    end

    def new_ticket_body
      preface = "Client called 211 EIP hotline and a VITA certified 211 specialist talked to the client and completed the intake form\n\n" if @intake.source == "211intake"
      preface.to_s + <<~BODY
        New EIP only form started

        Preferred name: #{@intake.preferred_name}
        Legal first name: #{@intake.primary_first_name}
        Legal last name: #{@intake.primary_last_name}
        Phone number: #{@intake.formatted_phone_number}
        Email: #{@intake.email_address}
        State of residence: #{@intake.state_of_residence_name}
        #{additional_ticket_messages}
        #{@intake.formatted_contact_preferences}
        This filer has consented to this VITA pilot.
      BODY
    end

    def new_ticket_fields
      notification_opt_ins = [
        ("sms_opt_in" if @intake.sms_notification_opt_in_yes?),
        ("email_opt_in" if @intake.email_notification_opt_in_yes?),
      ].compact

      fields = {
        EitcZendeskInstance::COMMUNICATION_PREFERENCES => notification_opt_ins,
        EitcZendeskInstance::EIP_STATUS => EitcZendeskInstance::EIP_STATUS_STARTED,
        EitcZendeskInstance::DOCUMENT_REQUEST_LINK => @intake.requested_docs_token_link,
        EitcZendeskInstance::INTAKE_SITE => "eip_only_return",
        EitcZendeskInstance::INTAKE_LANGUAGE => I18n.locale,
        EitcZendeskInstance::INTAKE_SOURCE => @intake.source,
        EitcZendeskInstance::STATE => @intake.state_of_residence,
        EitcZendeskInstance::CLIENT_ZIP_CODE => @intake.zip_code,
      }

      fields[EitcZendeskInstance::REFERRAL_BY_211] = true if @intake.source == "211intake"
      fields
    end

    def client_interview_preferences_message
      message = <<~MESSAGE
        Client's detected timezone: #{zendesk_timezone(@intake.timezone) || 'Unknown'}
        Client's provided interview preferences: #{@intake.interview_timing_preference || 'Unknown'}
      MESSAGE
      message.rstrip
    end

    def preferred_interview_language_name
      I18n.t("general.language_options.#{@intake.preferred_interview_language || I18n.locale}", locale: :en)
    end

    def additional_ticket_messages
      messages = ""
      diy_intakes = DiyIntake.where.not(email_address: nil).where(email_address: @intake.email_address)
      messages << "This client has previously requested a DIY link from GetYourRefund.org\n" if diy_intakes.count > 0
      full_service_intakes = Intake.where.not(email_address: nil).where.not(intake_ticket_id: nil).where(eip_only: [nil, false]).where(email_address: @intake.email_address)
      full_service_intakes.each do |intake|
        messages <<  "This client has a GetYourRefund full intake ticket: #{ticket_url(intake.intake_ticket_id)}"
      end

      messages
    end
  end
end
