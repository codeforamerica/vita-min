require "rails_helper"

describe EconomicImpactPaymentTwoCalculator do
  describe ".payment_due" do
    it "should return the correct payment amount based on eligible individuals and dependents" do
      payment_amount = described_class.payment_due(eligible_individuals: 1, eligible_dependents: 2)
      expect(payment_amount).to eq(1800)
    end
  end
end
