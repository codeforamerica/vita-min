class AddPersonToDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :person, :integer, default: 0, null: false
  end
end
