class AddColumnsToStateFileAnalytics < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_analytics, :az_pension_exclusion_government, :integer
    add_column :state_file_analytics, :az_pension_exclusion_uniformed_services, :integer
    add_column :state_file_analytics, :az_credit_for_contributions_to_qcos, :integer
    add_column :state_file_analytics, :az_credit_for_contributions_to_public_schools, :integer

    add_column :state_file_analytics, :nc_retirement_benefits_bailey, :integer
    add_column :state_file_analytics, :nc_retirement_benefits_uniformed_services, :integer

    add_column :state_file_analytics, :id_retirement_benefits_deduction, :integer

    add_column :state_file_analytics, :md_stpickup_addition, :integer
    add_column :state_file_analytics, :md_child_dep_care_subtraction, :integer
    add_column :state_file_analytics, :md_total_pension_exclusion, :integer
    add_column :state_file_analytics, :md_primary_pension_exclusion, :integer
    add_column :state_file_analytics, :md_spouse_pension_exclusion, :integer
    add_column :state_file_analytics, :md_ssa_benefits_subtraction, :integer
    add_column :state_file_analytics, :md_two_income_subtraction, :integer
    add_column :state_file_analytics, :md_income_us_gov_subtraction, :integer
    add_column :state_file_analytics, :md_military_retirement_subtraction, :integer
    add_column :state_file_analytics, :md_public_safety_subtraction, :integer
    add_column :state_file_analytics, :md_eic, :integer
    add_column :state_file_analytics, :md_poverty_credit, :integer
    add_column :state_file_analytics, :md_local_eic, :integer
    add_column :state_file_analytics, :md_local_poverty_credit, :integer
    add_column :state_file_analytics, :md_refundable_eic, :integer
    add_column :state_file_analytics, :md_child_dep_care_credit, :integer
    add_column :state_file_analytics, :md_senior_tax_credit, :integer
    add_column :state_file_analytics, :md_refundable_child_dep_care_credit, :integer
    add_column :state_file_analytics, :md_ctc, :integer
  end
end
