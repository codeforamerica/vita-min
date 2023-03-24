class AddMatchingPreviousYearIntakeForeignKeyToIntake < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :intakes, :intakes, column: :matching_previous_year_intake_id, validate: false
  end
end
