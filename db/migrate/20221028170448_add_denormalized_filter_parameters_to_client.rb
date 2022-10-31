class AddDenormalizedFilterParametersToClient < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :clients, :filterable_tax_return_states, :string, array: true
    add_index :clients, :filterable_tax_return_states, using: :gin, algorithm: :concurrently

    add_column :clients, :filterable_tax_return_assigned_users, :integer, array: true
    add_index :clients, :filterable_tax_return_assigned_users, using: :gin, algorithm: :concurrently

    add_column :clients, :filterable_tax_return_years, :integer, array: true
    add_index :clients, :filterable_tax_return_years, using: :gin, algorithm: :concurrently

    add_column :clients, :filterable_tax_return_service_types, :string, array: true
    add_index :clients, :filterable_tax_return_service_types, using: :gin, algorithm: :concurrently

    add_column :clients, :needs_to_flush_filterable_properties_set_at, :datetime
    add_index :clients, :needs_to_flush_filterable_properties_set_at, algorithm: :concurrently
  end
end
