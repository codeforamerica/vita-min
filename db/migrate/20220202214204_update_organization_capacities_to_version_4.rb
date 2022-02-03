class UpdateOrganizationCapacitiesToVersion4 < ActiveRecord::Migration[6.1]
  def change
    update_view :organization_capacities, version: 4, revert_to_version: 3
  end
end
