class ZendeskDiyIntakeService
  include ZendeskServiceHelper
  include AttachmentsHelper
  include ConsolidatedTraceHelper

  DIY_SUPPORT_GROUP_ID = "360010187593"
  DIY_SUPPORT_TICKET_FORM = "360003778974"
  DIY_SUPPORT_UNIQUE_LINK = "360041821734"

  def initialize(diy_intake)
    @diy_intake = diy_intake
  end

  def logger
    Rails.logger
  end

  def instance
    EitcZendeskInstance
  end

  def assign_requester
    requester_id = find_or_create_end_user(
      diy_intake.preferred_name,
      diy_intake.email_address,
      nil,
      exact_match: true
    )
    if requester_id
      diy_intake.update(requester_id: requester_id)
    else
      raise ZendeskServiceError.new(
        "ZendeskDiyIntakeService failed to create a ticket requester"
      )
    end
  end


  def create_diy_intake_ticket
    ticket_id = create_ticket(
      subject: ticket_subject,
      requester_id: diy_intake.requester_id,
      external_id: external_id,
      group_id: DIY_SUPPORT_GROUP_ID,
      ticket_form_id: DIY_SUPPORT_TICKET_FORM,
      body: ticket_body,
      fields: ticket_fields
    )
    if ticket_id
      diy_intake.update(ticket_id: ticket_id)
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

      send_diy_confirmation
    BODY
  end
  private

  attr_reader :diy_intake

  def ticket_fields
    {
      EitcZendeskInstance::STATE => diy_intake.state_of_residence,
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
