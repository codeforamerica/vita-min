class AddForeignKeyToAccessLogs < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_foreign_key :state_file_archived_intake_access_logs, :state_file_archived_intakes, validate: false
  end
end
