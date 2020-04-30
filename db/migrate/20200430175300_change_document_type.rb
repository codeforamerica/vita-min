class ChangeDocumentType < ActiveRecord::Migration[6.0]
  def up
    Document.where(document_type: "2018 Tax Return").update_all(document_type: "Prior Year Tax Return")
  end

  def down
    Document.where(document_type: "Prior Year Tax Return").update_all(document_type: "2018 Tax Return")
  end
end
