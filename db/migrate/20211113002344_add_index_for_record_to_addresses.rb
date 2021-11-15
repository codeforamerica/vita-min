class AddIndexForRecordToAddresses < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :addresses, [:record_type, :record_id], algorithm: :concurrently
  end
end
