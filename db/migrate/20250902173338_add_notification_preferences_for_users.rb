class AddNotificationPreferencesForUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :client_assignments_notification, :integer, default: 0, null: false
    add_column :users, :new_client_message_notification, :integer, default: 0, null: false
    add_column :users, :document_upload_notification, :integer, default: 0, null: false
    safety_assured { remove_column :users, :email_notification, :integer }
  end
end
