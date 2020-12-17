class CreateOrganizationLeadRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :organization_lead_roles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :vita_partner, null: false, foreign_key: true
      t.timestamps
    end
  end
end
