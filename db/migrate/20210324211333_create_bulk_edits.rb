class CreateBulkEdits < ActiveRecord::Migration[6.0]
  def change
    create_table :bulk_edits do |t|
      t.timestamps
      t.jsonb :data
    end
  end
end
