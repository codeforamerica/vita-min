namespace :backfill_incorrect_demographic_data do
  desc "Backfill incorrect demographic data"
  task backfill: :environment do
    intakes_with_incorrect_primary_data = Intake::GyrIntake.where(
      demographic_primary_american_indian_alaska_native: true,
      demographic_primary_asian: true,
      demographic_primary_black_african_american: true,
      demographic_primary_native_hawaiian_pacific_islander: true,
      demographic_primary_white: true,
      demographic_primary_prefer_not_to_answer_race: true,
    )
    intakes_with_incorrect_spouse_data = Intake::GyrIntake.where(
      demographic_spouse_american_indian_alaska_native: true,
      demographic_spouse_asian: true,
      demographic_spouse_black_african_american: true,
      demographic_spouse_native_hawaiian_pacific_islander: true,
      demographic_spouse_white: true,
      demographic_spouse_prefer_not_to_answer_race: true,
    )

    intakes_to_backfill = intakes_with_incorrect_primary_data.merge(intakes_with_incorrect_spouse_data)

    Sentry.capture_message "Backfill demographic data on intakes: beginning task with #{intakes_to_backfill.count} records to update"

    intakes_to_backfill.find_in_batches do |batch|
      batch.map do |intake|
        if intakes_with_incorrect_primary_data.include?(intake)
          intake.update(
            demographic_primary_american_indian_alaska_native: nil,
            demographic_primary_asian: nil,
            demographic_primary_black_african_american: nil,
            demographic_primary_native_hawaiian_pacific_islander: nil,
            demographic_primary_white: nil,
            demographic_primary_prefer_not_to_answer_race: nil,
          )
        end
        if intakes_with_incorrect_spouse_data.include?(intake)
          intake.update(
            demographic_spouse_american_indian_alaska_native: nil,
            demographic_spouse_asian: nil,
            demographic_spouse_black_african_american: nil,
            demographic_spouse_native_hawaiian_pacific_islander: nil,
            demographic_spouse_white: nil,
            demographic_spouse_prefer_not_to_answer_race: nil,
          )
        end
      end
    end

    intakes_to_backfill = Intake::GyrIntake.where(
      demographic_primary_american_indian_alaska_native: true,
      demographic_primary_asian: true,
      demographic_primary_black_african_american: true,
      demographic_primary_native_hawaiian_pacific_islander: true,
      demographic_primary_white: true,
      demographic_primary_prefer_not_to_answer_race: true,
    ).merge(Intake::GyrIntake.where(
      demographic_spouse_american_indian_alaska_native: true,
      demographic_spouse_asian: true,
      demographic_spouse_black_african_american: true,
      demographic_spouse_native_hawaiian_pacific_islander: true,
      demographic_spouse_white: true,
      demographic_spouse_prefer_not_to_answer_race: true,
    ))

    Sentry.capture_message "Backfill demographic data on intakes: ending task with #{intakes_to_backfill.count} records to update"
  end
end