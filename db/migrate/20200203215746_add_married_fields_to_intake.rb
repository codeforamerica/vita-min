class AddMarriedFieldsToIntake < ActiveRecord::Migration[5.2]
  def change
    change_table :intakes do |t|
      t.integer :married, default: 0, null: false
      t.integer :married_all_year, default: 0, null: false
      t.integer :lived_with_spouse, default: 0, null: false
      t.integer :separated, default: 0, null: false
      t.string :separated_year
      t.integer :divorced, default: 0, null: false
      t.string :divorced_year
      t.integer :widowed, default: 0, null: false
      t.string :widowed_year
    end
  end
end
