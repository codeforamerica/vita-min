class CreateDocumentsRequest < ActiveRecord::Migration[6.0]
  def change
    create_table :documents_requests do |t|
      t.belongs_to :intake, foreign_key: true
      t.timestamps
    end

    add_reference :documents, :documents_request, foreign_key: true
  end
end
