class AddMailgunIdAndStatusToOutgoingEmail < ActiveRecord::Migration[6.0]
  def change
    add_column :outgoing_emails, :mailgun_id, :string
    add_column :outgoing_emails, :mailgun_status, :string
  end
end
