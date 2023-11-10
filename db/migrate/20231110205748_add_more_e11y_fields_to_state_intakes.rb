class AddMoreE11yFieldsToStateIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_ny_intakes, :eligibility_out_of_state_income, :integer, default: 0, null: false
    add_column :state_file_ny_intakes, :eligibility_part_year_nyc_resident, :integer, default: 0, null: false
    add_column :state_file_ny_intakes, :eligibility_withdrew_529, :integer, default: 0, null: false

    add_column :state_file_az_intakes, :eligibility_out_of_state_income, :integer, default: 0, null: false
    add_column :state_file_az_intakes, :eligibility_529_for_non_qual_expense, :integer, default: 0, null: false
  end
end
