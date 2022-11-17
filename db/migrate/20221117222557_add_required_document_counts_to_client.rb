class AddRequiredDocumentCountsToClient < ActiveRecord::Migration[7.0]
  def change
    add_column :clients, :filterable_number_of_required_documents_uploaded, :integer, default: 0
    add_column :clients, :filterable_number_of_required_documents, :integer, default: 3
    add_column :clients, :filterable_percentage_of_required_documents_uploaded, :decimal, precision: 5, scale: 2, default: 0
  end
end
