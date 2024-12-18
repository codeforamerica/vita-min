class AddDfDataImportSucceededAtToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :df_data_import_succeeded_at, :datetime, null: true
    add_column :state_file_az_intakes, :df_data_import_succeeded_at, :datetime, null: true
    add_column :state_file_md_intakes, :df_data_import_succeeded_at, :datetime, null: true
    add_column :state_file_id_intakes, :df_data_import_succeeded_at, :datetime, null: true
    add_column :state_file_ny_intakes, :df_data_import_succeeded_at, :datetime, null: true
    add_column :state_file_nj_intakes, :df_data_import_succeeded_at, :datetime, null: true
  end
end
