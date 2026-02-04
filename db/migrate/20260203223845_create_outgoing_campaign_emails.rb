class CreateOutgoingCampaignEmails < ActiveRecord::Migration[7.1]
  def change
    create_table :outgoing_campaign_emails do |t|
      t.references :campaign_contact, null: false, foreign_key: true

      # from MailGun
      t.string :mailgun_message_id
      t.string :delivery_status, null: false, default: "created"
      t.string :error_code
      t.jsonb :event_data

      # details about message
      t.string :to_email
      t.string :from_email
      t.text :subject
      t.string :message_name

      t.datetime :sent_at
      t.timestamps
    end

    add_index :outgoing_campaign_emails, :mailgun_message_id, unique: true
  end
end
