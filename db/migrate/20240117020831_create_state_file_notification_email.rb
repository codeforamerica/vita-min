class CreateStateFileNotificationEmail < ActiveRecord::Migration[7.1]
  def change
    create_table "state_file_notification_emails" do |t|
      t.string "body", null: false
      t.datetime "created_at", null: false, precision: 6
      t.datetime "sent_at", precision: nil, null: true
      t.string "subject", null: false
      t.string "to", null: false
      t.string "mailgun_status", default: "sending"
      t.string "message_id"
      t.datetime "updated_at", null: false, precision: 6
    end
  end
end
