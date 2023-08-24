class ChangeDenyToRiskyOnFraudIndicatorDomain < ActiveRecord::Migration[6.1]
  def change
    safety_assured { rename_column :fraud_indicators_domains, :deny, :risky }
  end
end
