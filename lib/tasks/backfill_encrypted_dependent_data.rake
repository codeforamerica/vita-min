namespace :dependents do
  desc "Backfill ip and ssn to new encrypted column"
  task backfill: :environment do
    Dependent.where(ip_pin: nil).or(Dependent.where(ssn: nil)).find_each do |d|
      if d.read_attribute(:ip_pin).nil?
        d.update_column(:ip_pin, d.attr_encrypted_ip_pin)
      end
      if d.read_attribute(:ssn).nil?
        d.update_column(:ssn, d.attr_encrypted_ssn)
      end
    end
  end
end