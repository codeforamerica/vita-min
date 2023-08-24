class RemoveOldClientTaxReturnColumns < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :clients, :filterable_tax_return_states
      remove_column :clients, :filterable_tax_return_years
      remove_column :clients, :filterable_tax_return_assigned_users
      remove_column :clients, :filterable_tax_return_service_types
    end
  end
end
