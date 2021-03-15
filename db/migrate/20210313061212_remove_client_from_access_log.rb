class RemoveClientFromAccessLog < ActiveRecord::Migration[6.0]
  # Follow up migration for AddRecordToAccessLog
  def up
    update <<-SQL.squish
      UPDATE access_logs
      SET record_type = 'Client', record_id = client_id
      WHERE record_id IS NULL
    SQL
    update <<-SQL.squish
      UPDATE access_logs
      SET client_id = NULL
    SQL

    remove_reference :access_logs, :client, foreign_key: true
    change_column_null :access_logs, :record_id, false
    change_column_null :access_logs, :record_type, false
  end

  def down
    add_reference :access_logs, :client
    change_column_null :access_logs, :record_id, true
    change_column_null :access_logs, :record_type, true
  end
end
