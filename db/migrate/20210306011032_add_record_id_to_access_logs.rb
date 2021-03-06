class AddRecordIdToAccessLogs < ActiveRecord::Migration[6.0]
  def up
    add_reference :access_logs, :record, polymorphic: true, null: false
    AccessLog.all.find_each do |access_log|
      access_log.update(
        record_id: access_log.client_id,
      )
    end
    remove_column :access_logs, :client_id
  end

  def down
    add_reference :access_logs, :client, foreign_key: true
  end
end

