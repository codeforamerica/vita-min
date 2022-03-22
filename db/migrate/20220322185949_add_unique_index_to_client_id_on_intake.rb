class AddUniqueIndexToClientIdOnIntake < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    add_index :intakes, :client_id, unique: true, algorithm: :concurrently, name: :unique_index_intakes_on_client_id
    remove_index :intakes, :client_id, name: :index_intakes_on_client_id
    rename_index :intakes, :unique_index_intakes_on_client_id, :index_intakes_on_client_id
  end

  def down
    add_index :intakes, :client_id, algorithm: :concurrently, name: :nonunique_index_intakes_on_client_id
    remove_index :intakes, :client_id, name: :index_intakes_on_client_id
    rename_index :intakes, :nonunique_index_intakes_on_client_id, :index_intakes_on_client_id
  end
end
