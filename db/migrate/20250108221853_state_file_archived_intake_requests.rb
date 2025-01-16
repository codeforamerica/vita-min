class StateFileArchivedIntakeRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :state_file_archived_intake_requests do |t|
      t.belongs_to :state_file_archived_intakes, foreign_key: true
      t.string 'ip_address'
      t.string 'email_address'
      t.timestamps
    end

    remove_foreign_key :state_file_archived_intake_access_logs, :state_file_archived_intakes
    safety_assured { remove_column :state_file_archived_intake_access_logs, :state_file_archived_intakes_id }
  end
end
