class AddJointAccountHolderNameAndDirectDepositAuthorizationToStateFileMdIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_md_intakes, :bank_authorization_confirmed, :integer, default: 0, null: false
  end
end
