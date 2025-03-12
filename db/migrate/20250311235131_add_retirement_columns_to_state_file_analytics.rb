class AddRetirementColumnsToStateFileAnalytics < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_analytics, :az_pension_exclusion_government, :integer
    add_column :state_file_analytics, :az_pension_exclusion_uniformed_services, :integer

    add_column :state_file_analytics, :nc_retirement_benefits_bailey, :integer
    add_column :state_file_analytics, :nc_retirement_benefits_uniformed_services, :integer

    add_column :state_file_analytics, :id_retirement_benefits_deduction, :integer
  end
end
