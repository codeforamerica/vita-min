class AddDenormalizedJsonFilterParametersToClients < ActiveRecord::Migration[7.0]
  def change
    add_column :clients, :filterable_tax_return_properties, :jsonb
  end
end
