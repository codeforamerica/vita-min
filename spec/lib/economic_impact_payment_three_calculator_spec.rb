require "rails_helper"

describe EconomicImpactPaymentThreeCalculator do
  describe ".payment_due" do
    it "should return the correct payment amount based on eligible individuals and dependents" do
      expected_payment = 4200
      payment_amount = described_class.payment_due(filer_count: 1, dependent_count: 2)

      expect(payment_amount).to eq(expected_payment)
    end
  end
end
