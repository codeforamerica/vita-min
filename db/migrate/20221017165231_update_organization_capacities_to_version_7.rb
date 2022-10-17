class UpdateOrganizationCapacitiesToVersion7 < ActiveRecord::Migration[7.0]
  def change
    update_view :organization_capacities, version: 7, revert_to_version: 6
  end
end
