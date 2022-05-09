class RemoveOldRoutingNumberColumnsFromBankAccount < ActiveRecord::Migration[7.0]
  def up
    safety_assured do
      remove_columns :bank_accounts, :encrypted_routing_number, :encrypted_routing_number_iv, :hashed_routing_number
    end
  end

  def down;end
end
