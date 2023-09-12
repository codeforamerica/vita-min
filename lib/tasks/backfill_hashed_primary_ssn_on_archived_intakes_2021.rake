namespace :backfill_hashed_spouse_ssn_to_intake do
  desc "Backfill hashed_spouse_ssn on intakes with spouse_ssn value"
  task backfill: :environment do
    intakes_left_to_backfill =Intake.where(hashed_spouse_ssn: nil).where.not(spouse_ssn: nil)
    Sentry.capture_message "Backfill hashed_spouse_ssn on all intakes: beginning task with #{intakes_left_to_backfill.count} records to update"

    intakes_left_to_backfill.find_in_batches do |batch|
      Intake.upsert_all(
        batch.map { |intake|
          { id: intake.id, hashed_spouse_ssn: DeduplicationService.sensitive_attribute_hashed(intake, :spouse_ssn) }
        },
        update_only: [:hashed_spouse_ssn]
      )
    end

    intakes_left_to_backfill = Intake.where(hashed_spouse_ssn: nil).where.not(spouse_ssn: nil)
    Sentry.capture_message "Backfill hashed_spouse_ssn on intakes: ending task with #{intakes_left_to_backfill.count} records to update"
  end
end