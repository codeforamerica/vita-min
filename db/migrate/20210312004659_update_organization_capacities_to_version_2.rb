class UpdateOrganizationCapacitiesToVersion2 < ActiveRecord::Migration[6.0]
  def change
    replace_view :organization_capacities, version: 2, revert_to_version: 1
  end
end
