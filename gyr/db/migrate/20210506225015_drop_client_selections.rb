class DropClientSelections < ActiveRecord::Migration[6.0]
  def change
    remove_index :bulk_client_organization_updates, :client_selection_id
    remove_column :bulk_client_organization_updates, :client_selection_id

    remove_index :bulk_client_messages, :client_selection_id
    remove_column :bulk_client_messages, :client_selection_id

    remove_index :bulk_client_notes, :client_selection_id
    remove_column :bulk_client_notes, :client_selection_id

    drop_table :client_selection_clients
    drop_table :client_selections
  end
end
