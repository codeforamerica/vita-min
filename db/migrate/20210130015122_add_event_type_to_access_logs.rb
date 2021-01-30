class AddEventTypeToAccessLogs < ActiveRecord::Migration[6.0]
  def up
    add_column :access_logs, :event_type, :string
    AccessLog.all.find_each do |access_log|
      access_log.update(
        event_type: "read_bank_account_info",
      )
    end
    change_column_null :access_logs, :event_type, false
  end

  def down
    remove_column :access_logs, :event_type
  end
end
