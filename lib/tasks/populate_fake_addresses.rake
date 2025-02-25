namespace :state_file do
  desc "Populate fake addresses for existing StateFileArchivedIntake records"
  task populate_fake_addresses: :environment do
    missing_addresses = StateFileArchivedIntake.where(fake_address_1: nil).or(StateFileArchivedIntake.where(fake_address_2: nil))

    if missing_addresses.any?
      puts "Updating #{missing_addresses.count} records with fake addresses..."

      missing_addresses.find_each do |intake|
        intake.send(:populate_fake_addresses) # Calls private method
        if intake.save
          puts "Updated intake ID #{intake.id}"
        else
          puts "Failed to update intake ID #{intake.id}: #{intake.errors.full_messages.join(', ')}"
        end
      end

      puts "Fake address population complete."
    else
      puts "No records need updating."
    end
  end
end
