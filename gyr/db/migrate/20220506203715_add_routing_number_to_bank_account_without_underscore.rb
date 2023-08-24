class AddRoutingNumberToBankAccountWithoutUnderscore < ActiveRecord::Migration[7.0]
  def change
    add_column :bank_accounts, :routing_number, :string
  end
end
