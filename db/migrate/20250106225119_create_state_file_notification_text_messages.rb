class CreateStateFileNotificationTextMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :state_file_notification_text_messages do |t|
      t.string :body, null: false
      t.string :to_phone_number, null: false
      t.datetime :sent_at
      t.string :error_code
      t.string :twilio_sid
      t.string :twilio_status
      t.references :data_source, polymorphic: true, index: true

      t.timestamps
    end
  end
end
