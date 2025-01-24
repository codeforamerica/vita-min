class AddIncomeSourceToStateFileNc1099RFollowup < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc1099_r_followups, :income_source, :integer, default: 0, null: false
    add_column :state_file_nc1099_r_followups, :bailey_settlement_at_least_five_years, :integer, default: 0, null: false
    add_column :state_file_nc1099_r_followups, :bailey_settlement_from_retirement_plan, :integer, default: 0, null: false
    add_column :state_file_nc1099_r_followups, :uniformed_services_retired, :integer, default: 0, null: false
    add_column :state_file_nc1099_r_followups, :uniformed_services_qualifying_plan, :integer, default: 0, null: false
  end
end
