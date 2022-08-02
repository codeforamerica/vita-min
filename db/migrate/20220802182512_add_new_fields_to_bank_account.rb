class AddNewFieldsToBankAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :bank_accounts, :bank_name, :string
    add_column :bank_accounts, :account_number, :text
  end
end
