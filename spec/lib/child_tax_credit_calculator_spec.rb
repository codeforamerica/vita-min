require "rails_helper"

describe ChildTaxCreditCalculator do
  describe ".total_advance_payment" do
    it "returns the correct payment amount based on dependent counts" do
      expected_payment = 4800
      total_payment_amount = described_class.total_advance_payment(dependents_under_six_count: 1, dependents_six_and_over_count: 2)

      expect(total_payment_amount).to eq(expected_payment)
    end
  end
end
