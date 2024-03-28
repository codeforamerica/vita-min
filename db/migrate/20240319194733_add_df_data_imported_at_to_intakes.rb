class AddDfDataImportedAtToIntakes < ActiveRecord::Migration[7.1]
  def up
    add_column :state_file_az_intakes, :df_data_imported_at, :datetime, null: true
    add_column :state_file_ny_intakes, :df_data_imported_at, :datetime, null: true
  end

  def down
    remove_column :state_file_az_intakes, :df_data_imported_at
    remove_column :state_file_ny_intakes, :df_data_imported_at
  end
end
