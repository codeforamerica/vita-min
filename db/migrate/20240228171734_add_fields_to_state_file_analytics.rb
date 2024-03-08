class AddFieldsToStateFileAnalytics < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_analytics, :nys_eitc, :integer
    add_column :state_file_analytics, :nyc_eitc, :integer
    add_column :state_file_analytics, :empire_state_child_credit, :integer
    add_column :state_file_analytics, :nyc_school_tax_credit, :integer
    add_column :state_file_analytics, :nys_household_credit, :integer
    add_column :state_file_analytics, :nyc_household_credit, :integer
    add_column :state_file_analytics, :dependent_tax_credit, :integer
    add_column :state_file_analytics, :family_income_tax_credit, :integer
    add_column :state_file_analytics, :excise_credit, :integer
    add_column :state_file_analytics, :household_fed_agi, :integer
    safety_assured { remove_column :state_file_ny_intakes, :household_fed_agi, :integer }
  end
end