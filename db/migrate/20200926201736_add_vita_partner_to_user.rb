class AddVitaPartnerToUser < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :vita_partner, null: true, foreign_key: true
  end
end
