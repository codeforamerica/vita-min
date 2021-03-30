class AddArchivedToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :archived, :boolean, default: false, null: false
  end
end
