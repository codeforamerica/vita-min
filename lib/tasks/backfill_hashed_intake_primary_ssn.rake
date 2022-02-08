namespace :intakes do
  desc "Backfill hashed primary ssn onto intake objects"
  task backfill: :environment do
    Intake.where(hashed_primary_ssn: nil).where.not(encrypted_primary_ssn: nil).find_each do |intake|
      unless intake.primary_ssn.nil?
        intake.update(hashed_primary_ssn: DeduplificationService.sensitive_attribute_hashed(intake, :primary_ssn))
      end
    end
  end
end