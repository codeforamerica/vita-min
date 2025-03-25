class AddNewColumnsForStateFileId1099RFollowups < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_id1099_r_followups, :income_source, :integer, default: 0, null: false
    add_column :state_file_id1099_r_followups, :civil_service_account_number, :integer, default: 0, null: false
    add_column :state_file_id1099_r_followups, :police_retirement_fund, :integer, default: 0, null: false
    add_column :state_file_id1099_r_followups, :police_persi, :integer, default: 0, null: false
    add_column :state_file_id1099_r_followups, :firefighter_frf, :integer, default: 0, null: false
    add_column :state_file_id1099_r_followups, :firefighter_persi, :integer, default: 0, null: false
  end
end
