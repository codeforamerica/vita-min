require "rails_helper"

describe EconomicImpactPaymentTwoCalculator do
  describe ".payment_due" do
    context "when filer_count is zero" do
      it "returns 0 even if there are dependents" do
        expect(described_class.payment_due(filer_count: 0, dependent_count: 1)).to eq 0
      end
    end

    it "returns the correct payment amount based on eligible individuals and dependents" do
      expected_payment = 1800
      payment_amount = described_class.payment_due(filer_count: 1, dependent_count: 2)

      expect(payment_amount).to eq(expected_payment)
    end
  end
end
