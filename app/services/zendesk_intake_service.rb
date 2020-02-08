# zd_intake_service = ZendeskIntakeService.new(intake)
# zd_intake_service.create_intake_ticket_requester
# zd_ticket_id = zd_intake_service.create_intake_ticket
# intake.update(zendesk_ticket_id: zd_ticket_id)

class ZendeskIntakeService
  include ZendeskServiceHelper

  def initialize(intake)
    @intake = intake
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
      ONLINE_INTAKE_THC_UWBA
    elsif ONLINE_INTAKE_GWISR_STATES.include? @intake.state
      ONLINE_INTAKE_GWISR
    else
      ONLINE_INTAKE_UW_TUCSON
    end
  end

  def new_ticket_body
    <<~BODY
      #{new_ticket_body_header}

      Name: #{@intake.primary_user.full_name}
      Phone number: #{@intake.primary_user.formatted_phone_number}
      Email: #{@intake.primary_user.email}
      State (based on mailing address): #{@intake.state_name}

      #{new_ticket_body_footer}
    BODY
  end

  def new_ticket_fields
    {
      INTAKE_SITE => "online_intake",
      INTAKE_STATUS => "1._new_online_submission",
    }
  end

  private

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
end