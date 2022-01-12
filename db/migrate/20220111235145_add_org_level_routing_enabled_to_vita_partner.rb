class AddOrgLevelRoutingEnabledToVitaPartner < ActiveRecord::Migration[6.1]
  def change
    add_column :vita_partners, :org_level_routing_enabled, :boolean, default: true
  end
end
