class RemoveEmailNotificationColumnFromUser < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :users, :email_notification }
  end
end
