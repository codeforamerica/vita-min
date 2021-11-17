class OrganizationCapacityRenameToVitaPartnerCapacity < ActiveRecord::Migration[6.0]
  def change
    rename_table :organization_capacities, :vita_partner_capacities
  end
end
