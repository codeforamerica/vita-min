class RemoveStateFileArchivedIntakeRequestsFields < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :state_file_archived_intake_access_logs, :ip_address
      remove_column :state_file_archived_intake_requests, :details
    end
  end
end
