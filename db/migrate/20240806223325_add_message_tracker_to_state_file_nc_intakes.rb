class AddMessageTrackerToStateFileNcIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :message_tracker, :jsonb, default: {}
  end
end
