# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Efile::Md::TwoIncomeSubtractionWorksheet do
  before do
    instance.calculate
  end

  let(:intake) { create(:state_file_md_intake, :with_spouse) }
  let(:main_calculator) do
    Efile::Md::Md502Calculator.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end
  let(:instance) { main_calculator.instance_variable_get(:@two_income_subtraction_worksheet) }

  describe "#calculate_fed_income" do
    context "no fed income" do
      it "calculates the fed income amount for primary and spouse" do
        expect(instance.calculate_fed_income(:primary)).to eq(0)
        expect(instance.calculate_fed_income(:spouse)).to eq(0)
      end
    end
  end

  describe "#calculate_fed_subtractions" do
    context "no fed subtractions" do
      it "calculates the fed subtraction amount for primary and spouse" do
        expect(instance.calculate_fed_subtractions(:primary)).to eq(0)
        expect(instance.calculate_fed_subtractions(:spouse)).to eq(0)
      end
    end
  end

  describe "#calculate_line_1" do
    context "no fed income, no subtractions" do
      it "subtracts fed subtractions from fed income" do
        expect(instance.lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_1_PRIMARY].value).to eq(0)
        expect(instance.lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_1_SPOUSE].value).to eq(0)
      end
    end
  end

  describe "#calculate_line_2" do
    context "no state additions" do
      it "calculates the state addition amount for primary and spouse" do
        expect(instance.lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_2_PRIMARY].value).to eq(0)
        expect(instance.lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_2_SPOUSE].value).to eq(0)
      end
    end
  end

  describe "#calculate_line_3" do
    context "no fed income, no fed subtractions, no state additions" do
      it "adds state additions to current amount" do
        expect(instance.lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_3_PRIMARY].value).to eq(0)
        expect(instance.lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_3_SPOUSE].value).to eq(0)
      end
    end
  end

  describe "#calculate_line_4" do
    context "no state subtractions" do
      it "calculates the state subtraction amount for primary and spouse" do
        expect(instance.lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_4_PRIMARY].value).to eq(0)
        expect(instance.lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_4_SPOUSE].value).to eq(0)
      end
    end
  end

  describe "#calculate_line_5" do
    context "no fed income, no fed subtractions, no state additions" do
      it "subtracts state subtractions from current amount" do
        expect(instance.lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_5_PRIMARY].value).to eq(0)
        expect(instance.lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_5_SPOUSE].value).to eq(0)
      end
    end
  end

  describe "#calculate_line_6" do
    context "no agi" do
      it "returns the lower agi of the two filers" do
        expect(instance.lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_6].value).to eq(0)
      end
    end
  end

  describe "#calculate_line_7" do
    context "no agi" do
      it "returns the subtraction amount" do
        expect(instance.lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_6].value).to eq(0)
      end
    end
  end
end
