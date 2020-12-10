class CreateSite < ActiveRecord::Migration[6.0]
  def change
    create_table :sites do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
    end

    add_index :sites, [:organization_id, :name], unique: true
  end
end
