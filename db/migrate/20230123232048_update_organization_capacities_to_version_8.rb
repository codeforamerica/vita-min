class UpdateOrganizationCapacitiesToVersion8 < ActiveRecord::Migration[7.0]
  def change
    update_view :organization_capacities, version: 8, revert_to_version: 7
  end
end
