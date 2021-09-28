namespace :timezones do
  desc "Backfill timezones onto efile security information objects"
  task backfill: :environment do
    EfileSecurityInformation.where(timezone: nil).find_each do |esi|
      esi.update(timezone: esi&.client&.intake&.timezone)
      print "." if esi.timezone.present?
      print "-" if esi.timezone.nil?
    end
  end
end