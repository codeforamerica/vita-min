class AddRoutingNumberToBankAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :bank_accounts, :raw_routing_number, :string
  end
end
