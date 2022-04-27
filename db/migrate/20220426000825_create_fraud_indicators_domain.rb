class CreateFraudIndicatorsDomain < ActiveRecord::Migration[6.1]
  def change
    create_table :fraud_indicators_domains do |t|
      t.string :name
      t.timestamp :activated_at
      t.boolean :deny
      t.boolean :safe
      t.timestamps
      t.index :deny
      t.index :safe
    end
  end
end
