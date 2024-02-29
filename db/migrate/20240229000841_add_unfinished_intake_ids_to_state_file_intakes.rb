class AddUnfinishedIntakeIdsToStateFileIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :unfinished_intake_ids, :text, array: true, default: []
    add_column :state_file_ny_intakes, :unfinished_intake_ids, :text, array: true, default: []
  end
end
