class AddCoalitionToVitaPartner < ActiveRecord::Migration[6.0]
  def change
    add_reference :vita_partners, :coalition, null: true, foreign_key: true
    add_index :vita_partners, [:parent_organization_id, :name, :coalition_id], unique: true, name: "index_vita_partners_on_parent_name_and_coalition"
  end
end
