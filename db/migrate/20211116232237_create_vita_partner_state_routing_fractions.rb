class CreateVitaPartnerStateRoutingFractions < ActiveRecord::Migration[6.0]
  def change
    create_table :vita_partner_state_routing_fractions do |t|
      t.references :vita_partner, null: false, foreign_key: true
      t.references :state_routing_target, null: false, foreign_key: true, index: { name: 'index_vpsrf_on_state_routing_target_id' }
      t.float :routing_fraction, default: 0.0, null: false

      t.timestamps
    end
  end
end
