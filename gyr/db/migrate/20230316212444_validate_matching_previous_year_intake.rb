class ValidateMatchingPreviousYearIntake < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :intakes, :intakes, column: :matching_previous_year_intake_id
  end
end
