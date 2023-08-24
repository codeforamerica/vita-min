class CreateBulkClientMessage < ActiveRecord::Migration[6.0]
  def change
    create_table :bulk_client_messages do |t|
      t.timestamps
      t.references :client_selection, null: false, foreign_key: true
    end
  end
end
