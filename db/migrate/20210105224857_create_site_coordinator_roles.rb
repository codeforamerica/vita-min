class CreateSiteCoordinatorRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :site_coordinator_roles do |t|
      t.references :vita_partner, null: false, foreign_key: true
      t.timestamps
    end
  end
end