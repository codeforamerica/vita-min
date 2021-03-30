class CreateClientSelectionClient < ActiveRecord::Migration[6.0]
  def change
    create_table :client_selection_clients do |t|
      t.timestamps
      t.references :client_selection, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
    end
  end
end
