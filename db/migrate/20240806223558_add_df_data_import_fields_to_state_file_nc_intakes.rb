class AddDfDataImportFieldsToStateFileNcIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :df_data_imported_at, :datetime, null: true
    add_column :state_file_nc_intakes, :df_data_import_failed_at, :datetime, null: true
  end
end
