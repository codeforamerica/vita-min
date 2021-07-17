require "rails_helper"

describe CtcCalculator do
  describe ".monthly" do
    it "should return the correct monthly payment based on dependent counts" do
      expected_monthly = 850
      monthly = described_class.monthly(dependents_under_six_count: 1, dependents_over_six_count: 1)

      expect(monthly).to eq(expected_monthly)
    end
  end

  describe ".total" do
    it "should return the correct total payment based on dependent counts" do
      expected_total = 10200
      total = described_class.total(dependents_under_six_count: 1, dependents_over_six_count: 1)

      expect(total).to eq(expected_total)
    end
  end
end
