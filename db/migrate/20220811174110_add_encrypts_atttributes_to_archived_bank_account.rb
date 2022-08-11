class AddEncryptsAtttributesToArchivedBankAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :archived_bank_accounts_2021, :routing_number, :string
    add_column :archived_bank_accounts_2021, :account_number, :text
    add_column :archived_bank_accounts_2021, :bank_name, :string
  end
end
