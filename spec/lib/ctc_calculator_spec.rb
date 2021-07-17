require "rails_helper"

describe CtcCalculator do
  describe ".monthly_payment_due" do
    it "should return the correct payment amount based on dependent counts" do
      expected_payment = 850
      monthly_payment_amount = described_class.monthly_payment_due(dependents_under_six_count: 1, dependents_over_six_count: 1)

      expect(monthly_payment_amount).to eq(expected_payment)
    end
  end

  describe ".total_payment_due" do
    it "should return the correct payment amount based on dependent counts" do
      expected_payment = 10200
      total_payment_amount = described_class.total_payment_due(dependents_under_six_count: 1, dependents_over_six_count: 1)

      expect(total_payment_amount).to eq(expected_payment)
    end
  end
end
