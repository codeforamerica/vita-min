class CreateSiteCoordinatorRolesVitaPartners < ActiveRecord::Migration[7.0]
  def change
    create_table :site_coordinator_roles_vita_partners do |t|
      t.references :vita_partner, null: false, index: true
      t.references :site_coordinator_role, null: false, index: { name: "index_scr_vita_partners_on_scr_id" }

      t.timestamps
    end
  end
end
