class CreateDeletedDocumentHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :deleted_document_histories do |t|
      t.references :client, foreign_key: true
      t.integer :document_id
      t.string :display_name
      t.string :document_type
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
