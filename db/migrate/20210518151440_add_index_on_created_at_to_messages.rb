class AddIndexOnCreatedAtToMessages < ActiveRecord::Migration[6.0]
  def change
    add_index :incoming_emails, :created_at
    add_index :incoming_text_messages, :created_at
    add_index :incoming_portal_messages, :created_at
    add_index :outgoing_emails, :created_at
    add_index :outgoing_text_messages, :created_at
    add_index :outbound_calls, :created_at
  end
end
