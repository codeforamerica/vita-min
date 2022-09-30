class CreateW2Box14s < ActiveRecord::Migration[7.0]
  def change
    create_table :w2_box14s do |t|
      t.timestamps
      t.references :w2, null: false, foreign_key: true

      t.string :other_description
      t.decimal :other_amount, precision: 12, scale: 2
    end
  end
end
