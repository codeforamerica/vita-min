class CreateOrganizationCapacities < ActiveRecord::Migration[6.0]
  def change
    create_view :organization_capacities
  end
end
