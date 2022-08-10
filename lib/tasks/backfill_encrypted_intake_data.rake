namespace :backfill do
  desc "Backfill attr_encrypted intake columns to new encrypted columns"
  task intakes: :environment do
    Archived::Intake2021.where(primary_ssn: nil).where.not(encrypted_primary_ssn: nil).find_each do |i|
      i.update(primary_ssn: i.attr_encrypted_primary_ssn, # will update primary_last_four_ssn on callback
               spouse_ssn: i.attr_encrypted_spouse_ssn, # will update spouse_last_four_ssn on callback
               bank_name: i.attr_encrypted_bank_name,
               bank_account_number: i.attr_encrypted_bank_account_number,
               bank_routing_number: i.attr_encrypted_bank_routing_number,
               primary_ip_pin: i.attr_encrypted_primary_ip_pin,
               primary_signature_pin: i.attr_encrypted_primary_signature_pin,
               spouse_ip_pin: i.attr_encrypted_spouse_ip_pin,
               spouse_signature_pin: i.attr_encrypted_spouse_signature_pin,
               spouse_last_four_ssn: i.attr_encrypted_spouse_last_four_ssn,
               primary_last_four_ssn: i.attr_encrypted_primary_last_four_ssn
      )
    end
  end
end