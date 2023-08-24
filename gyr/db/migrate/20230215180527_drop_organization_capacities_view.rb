class DropOrganizationCapacitiesView < ActiveRecord::Migration[7.0]
  def change
    if ActiveRecord::Base.connection.view_exists? :organization_capacities
      drop_view :organization_capacities
    end
  end
end
