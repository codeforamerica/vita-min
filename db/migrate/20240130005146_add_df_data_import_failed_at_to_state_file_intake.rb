class AddDfDataImportFailedAtToStateFileIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :df_data_import_failed_at, :datetime, null: true
    add_column :state_file_ny_intakes, :df_data_import_failed_at, :datetime, null: true
  end
end
