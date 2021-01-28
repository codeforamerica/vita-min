class AddUniqueIndexToVitaPartnerState < ActiveRecord::Migration[6.0]
  def change
    add_index :vita_partner_states, [:state, :vita_partner_id], unique: true
  end
end
