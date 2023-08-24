class CreateAdminToggles < ActiveRecord::Migration[6.0]
  def change
    create_table :admin_toggles do |t|
      t.string :name
      t.json :value
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
