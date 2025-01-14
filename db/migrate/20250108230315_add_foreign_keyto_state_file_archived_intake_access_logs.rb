class AddForeignKeytoStateFileArchivedIntakeAccessLogs < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_archived_intake_access_logs, :state_file_archived_intake_request_id, :bigint
    add_foreign_key :state_file_archived_intake_access_logs, :state_file_archived_intake_requests, column: :state_file_archived_intake_request_id, validate: false
  end
end
