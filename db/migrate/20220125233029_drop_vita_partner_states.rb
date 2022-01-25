class DropVitaPartnerStates < ActiveRecord::Migration[6.1]
  def change
    drop_table :vita_partner_states
  end
end
