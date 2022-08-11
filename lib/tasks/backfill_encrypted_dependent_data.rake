namespace :backfill do
  desc "Backfill attr_encrypted dependent columns to new encrypted columns"
  task archived_dependents: :environment do
    Archived::Dependent2021.find_each do |d|
      d.update(ssn: d.attr_encrypted_ssn,
               ip_pin: d.attr_encrypted_ip_pin
      )
    end
  end
end