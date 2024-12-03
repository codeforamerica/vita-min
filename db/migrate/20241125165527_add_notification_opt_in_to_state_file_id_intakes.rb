class AddNotificationOptInToStateFileIdIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_id_intakes, :sms_notification_opt_in, :integer, default: 0, null: false
    add_column :state_file_id_intakes, :email_notification_opt_in, :integer, default: 0, null: false
  end
end
