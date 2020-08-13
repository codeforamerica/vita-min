module ZendeskIntakeAssignRequesterHelper
  def assign_requester
    return @intake.intake_ticket_requester_id if @intake.intake_ticket_requester_id.present?

    contact_info = @intake.contact_info_filtered_by_preferences
    requester_id = create_or_update_zendesk_user(
      name: @intake.preferred_name,
      email: contact_info[:email],
      phone: contact_info[:sms_phone_number],
      time_zone: zendesk_timezone(@intake.timezone),
    )
    @intake.update(intake_ticket_requester_id: requester_id)
  end
end
