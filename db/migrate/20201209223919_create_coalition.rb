class CreateCoalition < ActiveRecord::Migration[6.0]
  def change
    create_table :coalitions do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :coalitions, :name, unique: :true
  end
end
