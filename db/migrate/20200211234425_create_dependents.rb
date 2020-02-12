class CreateDependents < ActiveRecord::Migration[5.2]
  def change
    create_table :dependents do |t|
      t.references :intake, null: false, index: true
      t.string :first_name
      t.string :last_name
      t.date :birth_date
      t.string :relationship
      t.integer :months_in_home
      t.integer :was_student, null: false, default: 0
      t.integer :on_visa, null: false, default: 0
      t.integer :north_american_resident, null: false, default: 0
      t.integer :disabled, null: false, default: 0
      t.integer :was_married, null: false, default: 0
      t.timestamps
    end
  end
end
