class AddNotificationOptInToUser < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.integer :sms_notification_opt_in, null: false, default: 0
      t.integer :email_notification_opt_in, null: false, default: 0
    end
  end
end
