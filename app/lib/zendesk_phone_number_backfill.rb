# Backfills Zendesk phone numbers on intake tickets. This can be
# removed once it is run once in a production console.
#
# Usage (in rails console):
# > ZendeskPhoneNumberBackfill.update_zendesk!
#
class ZendeskPhoneNumberBackfill
  def self.update_zendesk!
    Intake.find_each do |intake|
      backfill_intake(intake)
    end

    IntakeSiteDropOff.find_each do |drop_off|
      backfill_drop_off(drop_off)
    end
  end

  private
  
  def self.backfill_intake(intake)
    return unless intake.intake_ticket_requester_id.present?

    service = ZendeskIntakeService.new(intake)
    user = service.get_end_user(user_id: intake.intake_ticket_requester_id)
    return unless user

    user.phone = intake.primary_user.standardized_phone_number
    user.save
  end

  def self.backfill_drop_off(drop_off)
    service = ZendeskDropOffService.new(drop_off)
    zendesk_user_id = service.find_end_user(drop_off.name, drop_off.email, drop_off.phone_number)
    return unless zendesk_user_id

    user = service.get_end_user(user_id: zendesk_user_id)
    user.phone = drop_off.standardized_phone_number
    user.save
  end
end
