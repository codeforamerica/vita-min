class AddOrgLevelRoutingEnabledToStateRoutingFractions < ActiveRecord::Migration[6.1]
  def change
    add_column :state_routing_fractions, :org_level_routing_enabled, :boolean
  end
end
