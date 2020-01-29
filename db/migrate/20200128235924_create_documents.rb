class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents do |t|
      t.string :document_type, null: false
      t.references :intake, index: true
      t.timestamps
    end
  end
end
