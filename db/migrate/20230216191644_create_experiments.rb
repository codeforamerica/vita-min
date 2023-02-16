class CreateExperiments < ActiveRecord::Migration[7.0]
  def change
    create_table :experiments do |t|
      t.string :key
      t.string :name
      t.boolean :enabled, default: false

      t.timestamps
    end
  end
end
