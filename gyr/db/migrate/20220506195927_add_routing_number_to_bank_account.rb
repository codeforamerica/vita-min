class AddRoutingNumberToBankAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :bank_accounts, :_routing_number, :string
  end
end
