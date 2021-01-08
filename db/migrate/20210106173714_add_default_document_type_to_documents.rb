class AddDefaultDocumentTypeToDocuments < ActiveRecord::Migration[6.0]
  def change
    change_column_default :documents, :document_type, from: nil, to: "Other"
  end
end
