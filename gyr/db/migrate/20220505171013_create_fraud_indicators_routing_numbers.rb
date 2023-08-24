class CreateFraudIndicatorsRoutingNumbers < ActiveRecord::Migration[6.1]
  def change
    create_table :fraud_indicators_routing_numbers do |t|
      t.string :routing_number
      t.string :bank_name
      t.timestamp :activated_at
      t.timestamps
    end
  end
end
