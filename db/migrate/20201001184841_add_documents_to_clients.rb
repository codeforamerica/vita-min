class AddDocumentsToClients < ActiveRecord::Migration[6.0]
  def change
    add_reference :documents, :client, foreign_key: true
    add_column :documents, :display_name, :string
  end
end
