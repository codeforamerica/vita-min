class AddExtraPointsToFraudIndicatorsRoutingNumbers < ActiveRecord::Migration[7.0]
  def change
    add_column :fraud_indicators_routing_numbers, :extra_points, :integer
  end
end
