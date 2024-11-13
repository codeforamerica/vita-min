# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Efile::Md::MdTwoIncomeSubtractionWorksheet do
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
  let(:instance) { main_calculator.instance_variable_get(:@md_two_income_subtraction_worksheet) }

  describe "#calculate_fed_income" do
    context "no income" do
      it "calculates the amount" do
        expect(instance.lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_1_PRIMARY].value).to eq(0)
        expect(instance.lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_1_SPOUSE].value).to eq(0)
      end
    end
  end
end
