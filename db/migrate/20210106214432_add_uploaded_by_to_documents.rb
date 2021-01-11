class AddUploadedByToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_reference :documents, :uploaded_by, polymorphic: true, null: true
  end
end
