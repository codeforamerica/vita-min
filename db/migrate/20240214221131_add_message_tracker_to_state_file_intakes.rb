class AddMessageTrackerToStateFileIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :message_tracker, :jsonb, default: {}
    add_column :state_file_ny_intakes, :message_tracker, :jsonb, default: {}
  end
end
