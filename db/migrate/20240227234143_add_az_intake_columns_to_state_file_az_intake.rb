class AddAzIntakeColumnsToStateFileAzIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :dependent_tax_credit, :integer
    add_column :state_file_az_intakes, :family_income_tax_credit, :integer
    add_column :state_file_az_intakes, :excise_credit, :integer
    add_column :state_file_az_intakes, :household_fed_agi, :integer
  end
end
