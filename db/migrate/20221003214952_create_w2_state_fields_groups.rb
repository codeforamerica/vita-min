class CreateW2StateFieldsGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :w2_state_fields_groups do |t|
      t.timestamps
      t.references :w2, null: false, foreign_key: true

      t.string :box15_state
      t.string :box15_employer_state_id_number
      t.decimal :box16_state_wages, precision: 12, scale: 2
      t.decimal :box17_state_income_tax, precision: 12, scale: 2
      t.decimal :box18_local_wages, precision: 12, scale: 2
      t.decimal :box19_local_income_tax, precision: 12, scale: 2
      t.string :box20_locality_name
    end
  end
end
