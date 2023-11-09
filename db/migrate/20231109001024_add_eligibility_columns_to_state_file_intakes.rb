class AddEligibilityColumnsToStateFileIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_ny_intakes, :eligibility_lived_in_state, :integer, default: 0, null: false
    add_column :state_file_ny_intakes, :eligibility_yonkers, :integer, default: 0, null: false

    add_column :state_file_az_intakes, :eligibility_lived_in_state, :integer, default: 0, null: false
    add_column :state_file_az_intakes, :eligibility_married_filing_separately, :integer, default: 0, null: false
  end
end
