class CreateSourceCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :source_codes do |t|
      t.string :code
      t.references :vita_partner, null: false, foreign_key: true

      t.timestamps
    end
    add_index :source_codes, :code
  end
end
