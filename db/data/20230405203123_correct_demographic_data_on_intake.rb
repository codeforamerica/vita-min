# frozen_string_literal: true

class CorrectDemographicDataOnIntake < ActiveRecord::Migration[7.0]
  def up
    # Only about 800 matching records in prod, no big need for batches
    intakes_with_incorrect_primary_data = Intake::GyrIntake.where(
      demographic_primary_american_indian_alaska_native: true,
      demographic_primary_asian: true,
      demographic_primary_black_african_american: true,
      demographic_primary_native_hawaiian_pacific_islander: true,
      demographic_primary_white: true,
      demographic_primary_prefer_not_to_answer_race: true,
    )
    intakes_with_incorrect_primary_data.update_all(
      {
        demographic_primary_american_indian_alaska_native: nil,
        demographic_primary_asian: nil,
        demographic_primary_black_african_american: nil,
        demographic_primary_native_hawaiian_pacific_islander: nil,
        demographic_primary_white: nil,
        demographic_primary_prefer_not_to_answer_race: nil,
      }
    )

    intakes_with_incorrect_spouse_data = Intake::GyrIntake.where(
      demographic_spouse_american_indian_alaska_native: true,
      demographic_spouse_asian: true,
      demographic_spouse_black_african_american: true,
      demographic_spouse_native_hawaiian_pacific_islander: true,
      demographic_spouse_white: true,
      demographic_spouse_prefer_not_to_answer_race: true,
    )
    intakes_with_incorrect_spouse_data.update_all(
      {
        demographic_spouse_american_indian_alaska_native: nil,
        demographic_spouse_asian: nil,
        demographic_spouse_black_african_american: nil,
        demographic_spouse_native_hawaiian_pacific_islander: nil,
        demographic_spouse_white: nil,
        demographic_spouse_prefer_not_to_answer_race: nil,
      }
    )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
