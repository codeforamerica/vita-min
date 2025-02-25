class AddIncomeSourceEligibilityToStateFileId1099RFollowup < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_id1099_r_followups, :eligible_income_source, :integer, default: 0, null: false
  end
end
