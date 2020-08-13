module Zendesk
  class EipService
    include ZendeskServiceHelper
    include ZendeskIntakeAssignRequesterHelper

    EIP_DUMMY_INTAKE_STATUS = "EIP".freeze

    def initialize(intake)
      @intake = intake
    end

    def instance
      EitcZendeskInstance
    end

    def create_eip_ticket
      return nil if @intake.intake_ticket_id.present?
      raise MissingRequesterIdError if @intake.intake_ticket_requester_id.blank?
      raise "Missing vita_partner" if @intake.vita_partner.nil?

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
          intake_status: EIP_DUMMY_INTAKE_STATUS,
          return_status: EitcZendeskInstance::EIP_STATUS_STARTED,
          ticket_id: ticket.id
        )
        @intake.update(intake_ticket_id: ticket.id)
        ticket_status.send_mixpanel_event
        ticket
      end
    end

    def new_ticket_subject
      test_ticket_suffix = (Rails.env.production? || Rails.env.test?) ? "" : " (Test Ticket)"
      @intake.primary_full_name + " EIP" + test_ticket_suffix
    end

    def new_ticket_body
      <<~BODY
        New EIP only form started

        Preferred name: #{@intake.preferred_name}
        Legal first name: #{@intake.primary_first_name}
        Legal last name: #{@intake.primary_last_name}
        Phone number: #{@intake.formatted_phone_number}
        Email: #{@intake.email_address}
        State of residence: #{@intake.state_of_residence_name}

        #{@intake.formatted_contact_preferences}
        This filer has consented to this VITA pilot.
      BODY
    end

    def new_ticket_fields
      notification_opt_ins = [
        ("sms_opt_in" if @intake.sms_notification_opt_in_yes?),
        ("email_opt_in" if @intake.email_notification_opt_in_yes?),
      ].compact

      {
        EitcZendeskInstance::COMMUNICATION_PREFERENCES => notification_opt_ins,
        EitcZendeskInstance::EIP_STATUS => EitcZendeskInstance::EIP_STATUS_STARTED,
        EitcZendeskInstance::DOCUMENT_REQUEST_LINK => @intake.requested_docs_token_link,
        EitcZendeskInstance::INTAKE_SITE => "eip_only_return",
        EitcZendeskInstance::INTAKE_LANGUAGE => I18n.locale,
        EitcZendeskInstance::INTAKE_SOURCE => @intake.source,
        EitcZendeskInstance::STATE => @intake.state_of_residence,
        EitcZendeskInstance::CLIENT_ZIP_CODE => @intake.zip_code,
      }
    end
  end
end
