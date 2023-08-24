class AddMatchingPreviousYearIntakeToIntake < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :intakes, :matching_previous_year_intake, index: { algorithm: :concurrently }
  end
end
