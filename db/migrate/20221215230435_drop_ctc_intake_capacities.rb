class DropCtcIntakeCapacities < ActiveRecord::Migration[7.0]
  def change
    drop_table :ctc_intake_capacities do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :capacity, null: false
      t.timestamps
      t.index :created_at
    end
  end
end
