class UndoRails61SchemaChanges < ActiveRecord::Migration[6.0]
  def up
    remove_column :active_storage_blobs, :service_name if column_exists?(:active_storage_blobs, :service_name)
    drop_table :active_storage_variant_records if table_exists?(:active_storage_variant_records)
  end

  def down
  end
end
