class CreateFraudScore < ActiveRecord::Migration[6.1]
  def change
    create_table :fraud_scores do |t|
      t.timestamps
      t.references :efile_submission
      t.jsonb :indicators
      t.integer :score
    end
  end
end
