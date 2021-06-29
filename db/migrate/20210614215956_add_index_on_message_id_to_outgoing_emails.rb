class AddIndexOnMessageIdToOutgoingEmails < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :outgoing_emails, :message_id, algorithm: :concurrently
  end
end
