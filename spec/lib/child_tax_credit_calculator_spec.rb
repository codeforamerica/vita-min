require "rails_helper"

describe ChildTaxCreditCalculator do
  describe ".monthly_payment_due" do
    it "returns the correct payment amount based on dependent counts" do
      expected_payment = 550
      monthly_payment_amount = described_class.monthly_payment_due(dependents_under_six_count: 1, dependents_over_six_count: 1)

      expect(monthly_payment_amount).to eq(expected_payment)
    end
  end

  describe ".total_payment_due" do
    it "returns the correct payment amount based on dependent counts" do
      expected_payment = 6600
      total_payment_amount = described_class.total_payment_due(dependents_under_six_count: 1, dependents_over_six_count: 1)

      expect(total_payment_amount).to eq(expected_payment)
    end
  end
end
