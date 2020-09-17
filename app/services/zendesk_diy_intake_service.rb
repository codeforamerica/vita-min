class ZendeskDiyIntakeService
  include ZendeskServiceHelper
  include AttachmentsHelper
  include ConsolidatedTraceHelper

  DIY_SUPPORT_GROUP_ID = "360010187593"
  DIY_TICKET_FORM = "360003778974"
  DIY_SUPPORT_UNIQUE_LINK = "360041821734"

  def initialize(diy_intake)
    @diy_intake = diy_intake
  end

  def instance
    EitcZendeskInstance
  end

  def assign_requester
    diy_intake.update(
      requester_id: create_or_update_zendesk_user(
        name: diy_intake.preferred_name,
        email: diy_intake.email_address,
      )
    )
  end

  def create_diy_intake_ticket
    ticket = create_ticket(
      subject: ticket_subject,
      requester_id: diy_intake.requester_id,
      external_id: external_id,
      group_id: DIY_SUPPORT_GROUP_ID,
      ticket_form_id: DIY_TICKET_FORM,
      body: ticket_body,
      fields: ticket_fields,
      tags: test_ticket_tags,
    )
    if ticket
      diy_intake.update(ticket_id: ticket.id)
      return ticket
    else
      raise ZendeskServiceError.new(
        "ZendeskDiyIntakeService failed to create a ticket for diy intake"
      )
    end
  end

  def ticket_subject
    suffix = (Rails.env.production? || Rails.env.test?) ? "" : " (Test Ticket)"
    "#{diy_intake.preferred_name} DIY Support#{suffix}"
  end

  def ticket_body
    <<~BODY
      New DIY Intake Started

      Preferred name: #{diy_intake.preferred_name}
      Email: #{diy_intake.email_address}
      State of residence: #{state_of_residence_name}
      Client has been sent DIY link via email

      #{additional_ticket_messages}
      send_diy_confirmation
    BODY
  end

  def append_resend_confirmation_email_comment
    append_comment_to_ticket(
      ticket_id: diy_intake.ticket_id,
      comment: resend_confirmation_email_comment_body,
      )
  end

  def resend_confirmation_email_comment_body
    <<~BODY
      DIY Intake Started with Duplicate Email

      Preferred name: #{diy_intake.preferred_name}
      Email: #{diy_intake.email_address}
      State of residence: #{state_of_residence_name}
      Client has been re-sent DIY link via email

      diy_confirmation_resend
    BODY
  end

  private

  attr_reader :diy_intake

  def additional_ticket_messages
    messages = []
    related_intakes = Intake.where.not(email_address: nil).where(email_address: diy_intake.email_address).filter { |i| i.intake_ticket_id.present? }
    related_intakes.each do |intake|
      messages <<  "This client has a GetYourRefund #{intake.eip_only? ? "EIP" : "full service"} ticket: #{ticket_url(intake.intake_ticket_id)}"
    end
    messages.join("\n")
  end

  def ticket_fields
    {
      EitcZendeskInstance::STATE => diy_intake.state_of_residence,
      EitcZendeskInstance::INTAKE_LANGUAGE => I18n.locale,
      DIY_SUPPORT_UNIQUE_LINK => diy_intake.start_filing_url,
    }
  end

  def external_id
    return unless diy_intake.id.present?

    ["diy-intake", diy_intake.id].join("-")
  end

  def state_of_residence_name
    States.name_for_key(diy_intake.state_of_residence)
  end
end
