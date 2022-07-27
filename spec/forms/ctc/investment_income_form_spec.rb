require 'rails_helper'

describe Ctc::InvestmentIncomeForm do
  let(:intake) { create :ctc_intake }
  let(:params) do
    {
      exceeded_investment_income_limit: "yes"
    }
  end

  describe "#save" do
    it "updates the intake with the value provided for exceeded_investment_income_limit" do
      expect {
        described_class.new(intake, params).save
      }.to change(intake, :exceeded_investment_income_limit).from("unfilled").to("yes")
    end
  end
end