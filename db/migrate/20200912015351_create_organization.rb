class CreateOrganization < ActiveRecord::Migration[6.0]
  def change
    create_table :organizations do |t|
      t.timestamps
      t.string :slug, null: false, unique: true
      t.string :name, null: false, unique: true
    end
  end
end
