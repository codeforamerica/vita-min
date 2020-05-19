class CreateSourceParameters < ActiveRecord::Migration[6.0]
  def change
    create_table :source_parameters do |t|
      t.string :code
      t.references :vita_partner, null: false, foreign_key: true

      t.timestamps
    end
    add_index :source_parameters, :code, unique: true
  end
end
