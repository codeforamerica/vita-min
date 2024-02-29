class AddPolymorphicDataSourceToStateFileNotificationEmail < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :state_file_notification_emails, :data_source, polymorphic: true, index: { algorithm: :concurrently }
  end
end
