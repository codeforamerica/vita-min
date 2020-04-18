class AddNotificationFieldsToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :email_notification_opt_in, :integer, default: 0, null: false
    add_column :intakes, :sms_notification_opt_in, :integer, default: 0, null: false
  end
end
