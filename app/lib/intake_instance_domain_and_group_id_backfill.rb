# Backfills Zendesk phone numbers on intake tickets. This can be
# removed once it is run once in a production console.
#
# Usage (in rails console):
# > ZendeskPhoneNumberBackfill.update_zendesk!
#
class IntakeInstanceDomainAndGroupIdBackfill
  def self.backfill_instance_domains!
    Intake.find_each do |intake|
      populate_instance_domain(intake)
    end
  end

  def self.backfill_group_ids!
    Intake.where(vita_partner_group_id: nil).each do |intake|
      populate_group_id(intake)
    end
    nil
  end

  private
  
  def self.populate_instance_domain(intake)
    puts "#######"
    puts "populating instance domain for Intake with id: #{intake.id}"
    intake.get_or_create_zendesk_instance_domain
  end

  def self.populate_group_id(intake)
    puts "#######"
    puts "populating group id for Intake with id: #{intake.id}"
    intake.assign_vita_partner!
  end
end
