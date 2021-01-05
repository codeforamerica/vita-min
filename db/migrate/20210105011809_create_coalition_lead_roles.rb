class CreateCoalitionLeadRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :coalition_lead_roles do |t|
      t.references :coalition, null: false, foreign_key: true
      t.timestamps
    end
  end
end
