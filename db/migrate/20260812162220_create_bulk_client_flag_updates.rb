class CreateBulkClientFlagUpdates < ActiveRecord::Migration[7.2]
  def change
    create_table :bulk_client_flag_updates do |t|
      t.references :tax_return_selection, null: false, foreign_key: true
      t.boolean :enabled, null: false

      t.timestamps
    end
  end
end
