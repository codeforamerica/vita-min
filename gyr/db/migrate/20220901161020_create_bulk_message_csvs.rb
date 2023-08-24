class CreateBulkMessageCsvs < ActiveRecord::Migration[7.0]
  def change
    create_table :bulk_message_csvs do |t|
      t.references :tax_return_selection, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :status
      t.timestamps
    end
  end
end
