class AddIncarceratedColumnsToStateFileAzIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :primary_was_incarcerated, :integer, default: 0, null: false
    add_column :state_file_az_intakes, :spouse_was_incarcerated, :integer, default: 0, null: false
    add_column :state_file_az_intakes, :household_excise_credit_claimed_amt, :integer
  end
end
