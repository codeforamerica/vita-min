class CreateIntake < ActiveRecord::Migration[5.2]
  def change
    create_table :intakes do |t|
      t.integer :has_wages, default: 0, null: false
      t.integer :has_scholarship_income, default: 0, null: false
    end
  end
end
