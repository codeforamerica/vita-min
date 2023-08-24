class CreateStateRoutingFraction < ActiveRecord::Migration[6.1]
  def change
    create_table :state_routing_fractions do |t|
      t.references :vita_partner, null: false, foreign_key: true
      t.references :state_routing_target, null: false, foreign_key: true
      t.float :routing_fraction, default: 0, null: false
      t.timestamps
    end
  end
end
