class AddCachedDataToBulkClientMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_client_messages, :cached_data, :jsonb, default: {}
  end
end
