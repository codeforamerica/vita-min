class CreateCtcIntakeCapacities < ActiveRecord::Migration[6.0]
  def change
    create_table :ctc_intake_capacities do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :capacity, null: false
      t.timestamps
      t.index :created_at
    end
  end
end
