class CreateGroup < ActiveRecord::Migration[6.0]
  def change
    create_table :groups do |t|
      t.timestamps
      t.references :organization, null: false
      t.string :name, null: false
      t.string :description
    end
  end
end
