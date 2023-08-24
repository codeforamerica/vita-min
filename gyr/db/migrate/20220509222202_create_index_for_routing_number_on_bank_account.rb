class CreateIndexForRoutingNumberOnBankAccount < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!
  def change
    add_index :bank_accounts, :routing_number, algorithm: :concurrently
  end
end
