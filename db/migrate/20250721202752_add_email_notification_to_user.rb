class AddEmailNotificationToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :email_notification, :integer, default: 1, null: false
  end
end
