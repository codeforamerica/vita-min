class CreateFraudIndicators < ActiveRecord::Migration[6.1]
  def change
    create_table :fraud_indicators do |t|
      t.string :name
      t.string :indicator_type
      t.string :source_table_name
      t.decimal :threshold
      t.string :reference
      t.string :list_table_name
      t.string :indicator_attributes, array: true, default: []
      t.integer :points
      t.decimal :multiplier
      t.timestamp :active_at
      t.timestamps
    end
  end
end
