class IndexClientsFilterableTaxReturnProperties < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :clients, :filterable_tax_return_properties, using: :gin, algorithm: :concurrently
  end
end
