class AddEligibilityHomebuyerWithdrawalToStateFileMdIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_md_intakes, :eligibility_homebuyer_withdrawal, :integer, null: false, default: 0
  end
end
