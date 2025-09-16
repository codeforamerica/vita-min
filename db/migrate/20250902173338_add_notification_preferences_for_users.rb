class AddNotificationPreferencesForUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :client_assignments_notification, :integer, default: 0, null: false
    add_column :users, :new_client_message_notification, :integer, default: 0, null: false
    add_column :users, :document_upload_notification, :integer, default: 0, null: false
    add_column :users, :tagged_in_note_notification, :integer, default: 0, null: false
    add_column :users, :signed_8879_notification, :integer, default: 0, null: false
  end
end
