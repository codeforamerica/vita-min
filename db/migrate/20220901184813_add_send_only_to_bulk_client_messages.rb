class AddSendOnlyToBulkClientMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_client_messages, :send_only, :string
  end
end
