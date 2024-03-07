class CreateDfDataImportErrors < ActiveRecord::Migration[7.1]
  def change
    create_table :df_data_import_errors do |t|
      t.references :state_file_intake, polymorphic: true, index: true
      t.string "message"
      t.timestamps
    end
  end
end
