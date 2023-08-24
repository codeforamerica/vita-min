class AddDefaultMailgunStatusToOutgoingEmails < ActiveRecord::Migration[6.0]
  def change
    change_column_default :outgoing_emails, :mailgun_status, from: nil, to: "sending"
  end
end
