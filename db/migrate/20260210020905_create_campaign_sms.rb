class CreateCampaignSms < ActiveRecord::Migration[7.1]
  def change
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

    add_index :campaign_sms, [:message_name, :to_phone_number], unique: true
    add_index :campaign_sms, :twilio_sid, unique: true
  end
end
