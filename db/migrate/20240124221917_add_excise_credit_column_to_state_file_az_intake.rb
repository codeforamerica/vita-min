class AddExciseCreditColumnToStateFileAzIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :ssn_no_employment, :integer, default: 0, null: false
    add_column :state_file_az_intakes, :household_excise_credit_claimed, :integer, default: 0, null: false
  end
end
