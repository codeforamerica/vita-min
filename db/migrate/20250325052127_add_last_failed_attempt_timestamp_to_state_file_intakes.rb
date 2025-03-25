class AddLastFailedAttemptTimestampToStateFileIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :last_failed_attempt_at, :datetime, precision: 6, null: true
    add_column :state_file_id_intakes, :last_failed_attempt_at, :datetime, precision: 6, null: true
    add_column :state_file_md_intakes, :last_failed_attempt_at, :datetime, precision: 6, null: true
    add_column :state_file_nc_intakes, :last_failed_attempt_at, :datetime, precision: 6, null: true
    add_column :state_file_nj_intakes, :last_failed_attempt_at, :datetime, precision: 6, null: true
    add_column :state_file_ny_intakes, :last_failed_attempt_at, :datetime, precision: 6, null: true
  end
end
