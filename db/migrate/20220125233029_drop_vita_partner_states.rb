class DropVitaPartnerStates < ActiveRecord::Migration[6.1]
  def up
    drop_table :vita_partner_states
  end

  def down

  end
end
