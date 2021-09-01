require "rails_helper"

describe ChildTaxCreditCalculator do
  let(:intake) { create :ctc_intake }
  let!(:dependent_older_than_6){ create :dependent, birth_date: 10.years.ago, intake: intake }
  let!(:dependent_exactly_6){ create :dependent, birth_date: 6.years.ago, intake: intake }
  let!(:dependent_younger_than_6){ create :dependent, birth_date: 4.years.ago, intake: intake }

  describe ".monthly_payment_due" do
    it "returns the correct payment amount based on dependent counts" do
      expected_payment = 800
      monthly_payment_amount = described_class.monthly_payment_due(intake.dependents)

      expect(monthly_payment_amount).to eq(expected_payment)
    end
  end

  describe ".total_advance_payment_2021" do
    it "returns the correct payment amount based on dependent counts" do
      expected_payment = 4800
      total_payment_amount = described_class.total_advance_payment_2021(intake.dependents)

      expect(total_payment_amount).to eq(expected_payment)
    end
  end
end
