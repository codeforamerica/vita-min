class ValidateForeignKeyforStateFileArchivedIntakeAccessLogs < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :state_file_archived_intake_access_logs, :state_file_archived_intake_requests
  end
end
