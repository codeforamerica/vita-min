class AddRecordIdToAccessLogs < ActiveRecord::Migration[6.0]
  def up
    add_reference :access_logs, :record, polymorphic: true, null: true
    AccessLog.all.find_each do |access_log|
      access_log.update(
        record_id: access_log.client_id,
        record_type: "Client",
      )
    end
    change_column_null :access_logs, :record_id, false
    change_column_null :access_logs, :record_type, false
    remove_column :access_logs, :client_id
  end

  def down
    remove_reference :access_logs, :record, polymorphic: true
    add_column :access_logs, :client_id, :integer
  end
end

