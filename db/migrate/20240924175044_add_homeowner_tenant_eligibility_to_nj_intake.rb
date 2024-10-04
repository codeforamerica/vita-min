class AddHomeownerTenantEligibilityToNjIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :homeowner_home_subject_to_property_taxes, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :homeowner_more_than_one_main_home_in_nj, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :homeowner_shared_ownership_not_spouse, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :homeowner_main_home_multi_unit, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :homeowner_main_home_multi_unit_max_four_one_commercial, :integer, default: 0, null: false
  end
end
