class AddVitaPartnerToClients < ActiveRecord::Migration[6.0]
  def change
    add_reference :clients, :vita_partner, null: true, foreign_key: true
  end
end
