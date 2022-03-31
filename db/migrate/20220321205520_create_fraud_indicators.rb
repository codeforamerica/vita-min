class CreateFraudIndicators < ActiveRecord::Migration[6.1]
  def change
    create_table :fraud_indicators do |t|
      t.string :name
      t.string :indicator_type
      t.string :query_model_name
      t.float :threshold
      t.string :reference
      t.string :list_model_name
      t.string :indicator_attributes, array: true, default: []
      t.integer :points
      t.float :multiplier
      t.text :description
      t.timestamp :activated_at
      t.timestamps
    end
  end
end
