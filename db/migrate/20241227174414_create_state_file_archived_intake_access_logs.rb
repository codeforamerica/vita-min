class CreateStateFileArchivedIntakeAccessLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :state_file_archived_intake_access_logs do |t|
      t.belongs_to 'state_file_archived_intakes', foreign_key: true
      t.integer 'event_type'
      t.jsonb 'details', default: '{}'
      t.timestamps
    end
  end
end
