class CreateCampaignEmails < ActiveRecord::Migration[7.1]
  def change
    create_table :campaign_emails do |t|
      t.references :campaign_contact, null: false, foreign_key: true

      # from Mailgun
      t.string :mailgun_message_id
      t.string :mailgun_status, null: false, default: "created"
      t.string :error_code
      t.jsonb :event_data

      # message details
      t.string :to_email
      t.string :from_email
      t.text :subject
      t.string :message_name

      t.datetime :scheduled_send_at
      t.datetime :sent_at
      t.timestamps
    end

    add_index :campaign_emails, :mailgun_message_id, unique: true
    add_index :campaign_emails, [:campaign_contact_id, :message_name],
              unique: true,
              name: "index_campaign_emails_on_contact_id_and_message_name"
  end
end
