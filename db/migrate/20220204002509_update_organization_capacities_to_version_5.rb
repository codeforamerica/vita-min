class UpdateOrganizationCapacitiesToVersion5 < ActiveRecord::Migration[6.1]
  def change
    update_view :organization_capacities, version: 5, revert_to_version: 4

  end
end
