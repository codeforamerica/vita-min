class AddTenantEligibilityToNjIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :tenant_home_subject_to_property_taxes, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :tenant_building_multi_unit, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :tenant_access_kitchen_bath, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :tenant_more_than_one_main_home_in_nj, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :tenant_shared_rent_not_spouse, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :tenant_same_home_spouse, :integer, default: 0, null: false
  end
end
