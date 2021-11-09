class BackfillTypeOnVitaPartner < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def up
    orgs = VitaPartner.where(parent_organization_id: nil)
    orgs.update_all(type: "Organization")

    sites = VitaPartner.where.not(parent_organization_id: nil)
    sites.update_all(type: "Site")
  end

  def down
    VitaPartner.all.update_all(type: nil)
  end
end
