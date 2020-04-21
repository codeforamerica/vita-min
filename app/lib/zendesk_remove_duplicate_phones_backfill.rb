# Delete duplicate phone numbers: changing the user's phone number will
# result in Zendesk creating a new "identity" for the user and the old phone
# number will persist. Zendesk appears to send SMS to the first (oldest)
# identity associated with an end user, so these old identities need to be
# removed.
#
# Usage (in rails console):
# > ZendeskRemoveDuplicatePhonesBackfill.update_zendesk!
#
class ZendeskRemoveDuplicatePhonesBackfill
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

    expected_phone = intake.primary_user.standardized_phone_number

    # If the phone number has been changed by an agent (i.e. it is not what we
    # expect it to be), don't do anything
    if user.phone == expected_phone
      delete_duplicate_identities(user, expected_phone)
    end
  end

  def self.backfill_drop_off(drop_off)
    service = ZendeskDropOffService.new(drop_off)
    zendesk_user_id = service.find_end_user(drop_off.name, drop_off.email, drop_off.phone_number)
    return unless zendesk_user_id

    user = service.get_end_user(user_id: zendesk_user_id)
    return unless user

    delete_duplicate_identities(user, drop_off.standardized_phone_number)
  end

  def self.delete_duplicate_identities(user, standardized_phone)
    phone_without_plus = standardized_phone.gsub(/^\+/, "")
    phone_without_plus_and_one = standardized_phone.gsub(/^\+1/, "")

    user
      .identities
      .find_all { |i| i.type == "phone_number" }
      .find_all { |i| i.value == phone_without_plus || i.value == phone_without_plus_and_one }
      .map(&:destroy)
  end
end
