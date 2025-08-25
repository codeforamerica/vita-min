class CreateUserNotificationEmails < ActiveRecord::Migration[7.1]
  def change
    create_table :user_notification_emails do |t|
      t.references :user_notification, null: false, foreign_key: true
      t.string :body, null: false
      t.datetime :sent_at, precision: nil, null: true
      t.string :subject, null: false
      t.string :to, null: false
      t.string :mailgun_status, default: "sending"
      t.string :message_id

      t.timestamps
    end
  end
end
