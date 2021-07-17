require "rails_helper"

describe EipTwoCalculator do
  describe ".amount" do
    it "should return the correct payment amount based on filer and dependent counts" do
      expected_amount = 1800
      amount = described_class.amount(filer_count: 1, dependent_count: 2)

      expect(amount).to eq(expected_amount)
    end
  end
end
