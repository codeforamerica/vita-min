class AddCoalitionToVitaPartner < ActiveRecord::Migration[6.0]
  def change
    add_reference :vita_partners, :coalition, null: true, foreign_key: true
  end
end
