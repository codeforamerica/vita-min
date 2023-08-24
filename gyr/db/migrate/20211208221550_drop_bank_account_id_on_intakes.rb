class DropBankAccountIdOnIntakes < ActiveRecord::Migration[6.1]
  def change
    if column_exists?(:intakes, :bank_account_id)
      remove_column :intakes, :bank_account_id
    end
    if table_exists?(:archived_intakes_2021) && column_exists?(:archived_intakes_2021, :bank_account_id)
      remove_column :archived_intakes_2021, :bank_account_id
    end
  end
end
