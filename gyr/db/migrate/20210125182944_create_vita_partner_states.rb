class CreateVitaPartnerStates < ActiveRecord::Migration[6.0]
  def change
    create_table :vita_partner_states do |t|
      t.references :vita_partner, null: false, foreign_key: true
      t.string :state, null: false
      t.float :routing_fraction, default: 0, null: false
      t.timestamps
    end
  end
end
