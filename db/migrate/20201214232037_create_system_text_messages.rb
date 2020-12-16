class CreateSystemTextMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :system_text_messages do |t|
      t.string :body, null: false
      t.datetime :sent_at, null: false
      t.string :to_phone_number, null: false
      t.string :twilio_sid
      t.string :twilio_status
      t.references :client, null: false, foreign_key: true
      t.timestamps
    end
  end
end
