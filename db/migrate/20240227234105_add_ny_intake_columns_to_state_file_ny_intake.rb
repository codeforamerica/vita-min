class AddNyIntakeColumnsToStateFileNyIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_ny_intakes, :nys_eitc, :integer
    add_column :state_file_ny_intakes, :nyc_eitc, :integer
    add_column :state_file_ny_intakes, :empire_state_child_credit, :integer
    add_column :state_file_ny_intakes, :nyc_school_tax_credit, :integer
    add_column :state_file_ny_intakes, :nys_household_credit, :integer
    add_column :state_file_ny_intakes, :nyc_household_credit, :integer
  end
end
