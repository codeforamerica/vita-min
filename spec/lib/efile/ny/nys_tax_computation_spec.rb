require 'rails_helper'

describe Efile::Ny::NysTaxComputation do
  describe "calculate" do
    it "returns the expected value for a case that was throwing an error" do
      agi = 118_287
      taxable_income = 101_237
      filing_status = :married_filing_jointly
      result = Efile::Ny::NysTaxComputation.calculate(agi, taxable_income, filing_status)
      expect(result).to eq 5_306.257_75
    end
  end
end
