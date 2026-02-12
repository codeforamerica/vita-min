class RepairCampaignSchemaOnStaging < ActiveRecord::Migration[7.1]
  def change
    # ---- campaign_emails: add missing column(s) ----
    add_column :campaign_emails, :scheduled_send_at, :datetime unless column_exists?(:campaign_emails, :scheduled_send_at)

    # ---- campaign_sms: create table if missing ----
    unless table_exists?(:campaign_sms)
      create_table :campaign_sms do |t|
        t.references :campaign_contact, null: false, foreign_key: true

        t.string :to_phone_number, null: false
        t.string :message_name, null: false

        # message details
        t.text :body, null: false

        # from Twilio
        t.string :twilio_sid
        t.string :twilio_status
        t.string :error_code
        t.jsonb :event_data

        t.datetime :scheduled_send_at
        t.datetime :sent_at
        t.timestamps
      end
    end

    # ---- campaign_sms: ensure indexes exist ----
    unless index_exists?(:campaign_sms, [:message_name, :to_phone_number], unique: true, name: "index_campaign_sms_on_message_name_and_to_phone_number")
      add_index :campaign_sms, [:message_name, :to_phone_number],
                unique: true, name: "index_campaign_sms_on_message_name_and_to_phone_number"
    end

    add_index :campaign_sms, :campaign_contact_id unless index_exists?(:campaign_sms, :campaign_contact_id)

    unless index_exists?(:campaign_sms, :twilio_sid, unique: true, name: "index_campaign_sms_on_twilio_sid")
      add_index :campaign_sms, :twilio_sid, unique: true, name: "index_campaign_sms_on_twilio_sid"
    end
  end
end
