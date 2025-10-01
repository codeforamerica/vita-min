class RemoveEmailNotificationsColumnFromUsersTable < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :users, :email_notification, :integer }
  end
end
