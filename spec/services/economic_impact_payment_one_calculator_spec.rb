require "rails_helper"

describe EconomicImpactPaymentOneCalculator do
  describe ".payment_due" do
    it "should return the correct payment amount based on filer and dependent counts" do
      payment_amount = described_class.payment_due(filer_count: 1, dependent_count: 2)
      expect(payment_amount).to eq(2200)
    end
  end
end
