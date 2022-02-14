class UpdateOrganizationCapacitiesToVersion6 < ActiveRecord::Migration[6.1]
  class UpdateOrganizationCapacitiesToVersion5 < ActiveRecord::Migration[6.1]
    def change
      update_view :organization_capacities, version: 6, revert_to_version: 5
    end
  end
end
