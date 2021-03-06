class ChangeDefaultDocumentTypeOnDocuments < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:documents, :document_type, from: "Other", to: nil)
  end
end
