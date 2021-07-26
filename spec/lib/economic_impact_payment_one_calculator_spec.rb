require "rails_helper"

describe EconomicImpactPaymentOneCalculator do
  describe ".payment_due" do
    context "when filer_count is 0" do
      it "returns 0 even if dependent_count is greater than 0" do
        expect(described_class.payment_due(filer_count: 0, dependent_count: 1)).to eq 0
      end
    end

    it "returns the correct payment amount based on filer and dependent counts" do
      expected_payment = 2200
      payment_amount = described_class.payment_due(filer_count: 1, dependent_count: 2)

      expect(payment_amount).to eq(expected_payment)
    end
  end
end
