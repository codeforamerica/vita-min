class AddNotificationPreferencesForUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :client_messages_notification, :integer, default: 0, null: false
    add_column :users, :client_assignments_notification, :integer, default: 0, null: false
    add_column :users, :document_uploads_notification, :integer, default: 0, null: false
  end
end
