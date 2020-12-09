class CreateOrganization < ActiveRecord::Migration[6.0]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.references :coalition

      t.timestamps
    end

    add_index :organizations, :name, unique: :true
  end
end
