class RenameVitaPartnerStatesToStateRoutingTargets < ActiveRecord::Migration[6.0]
  def change
    rename_table :vita_partner_states, :state_routing_targets
  end
end