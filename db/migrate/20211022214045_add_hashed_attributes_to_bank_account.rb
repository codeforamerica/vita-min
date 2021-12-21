class AddHashedAttributesToBankAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :bank_accounts, :hashed_routing_number, :string
    add_column :bank_accounts, :hashed_account_number, :string
    add_index :bank_accounts, :hashed_account_number
    add_index :bank_accounts, :hashed_routing_number
  end
end
