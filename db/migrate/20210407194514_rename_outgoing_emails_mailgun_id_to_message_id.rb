class RenameOutgoingEmailsMailgunIdToMessageId < ActiveRecord::Migration[6.0]
  def change
    rename_column :outgoing_emails, :mailgun_id, :message_id
  end
end
