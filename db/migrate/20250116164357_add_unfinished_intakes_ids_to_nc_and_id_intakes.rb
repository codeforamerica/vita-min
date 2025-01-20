class AddUnfinishedIntakesIdsToNcAndIdIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :unfinished_intake_ids, :text, array: true, default: []
    add_column :state_file_id_intakes, :unfinished_intake_ids, :text, array: true, default: []
  end
end
