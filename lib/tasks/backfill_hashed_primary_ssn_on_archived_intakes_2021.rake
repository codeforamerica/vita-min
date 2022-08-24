namespace :backfill_hashed_primary_ssn_on_archived_intakes_2021 do
  desc "Backfill hashed_primary_ssn on archived_intakes_2021 with primary_ssn value"
  task backfill: :environment do
    intakes_left_to_backfill = Archived::Intake2021.where(hashed_primary_ssn: nil).where.not(primary_ssn: nil)
    Sentry.capture_message "Backfill hashed_primary_ssn on archived_intakes_2021: beginning task with #{intakes_left_to_backfill.count} records to update"

    # find each
    # intakes_left_to_backfill.find_each(batch_size: 100) do |archived_intake|
    #   archived_intake.update(hashed_primary_ssn: DeduplificationService.sensitive_attribute_hashed(archived_intake, :primary_ssn))
    # end

    # OR

    # update all
    intakes_left_to_backfill.find_in_batches do |batch|
      Archived::Intake2021.upsert_all(
        batch.map { |archived_intake| archived_intake.attributes.merge(hashed_primary_ssn: DeduplificationService.sensitive_attribute_hashed(archived_intake, :primary_ssn)) },
        update_only: [:hashed_primary_ssn]
      )
    end

    intakes_left_to_backfill = Archived::Intake2021.where(hashed_primary_ssn: nil).where.not(primary_ssn: nil)
    Sentry.capture_message "Backfill hashed_primary_ssn on archived_intakes_2021: ending task with #{intakes_left_to_backfill.count} records to update"
  end
end