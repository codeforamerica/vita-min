class AddStateFileArchivedIntakeToAccessLogs < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :state_file_archived_intake_access_logs, :state_file_archived_intake, null: true, index: false
  end
end
