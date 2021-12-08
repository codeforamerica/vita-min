class DropBankAccountIdOnIntakes < ActiveRecord::Migration[6.1]
  def change
    remove_column :intakes, :bank_account_id
  end
end
