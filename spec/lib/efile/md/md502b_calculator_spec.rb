require 'rails_helper'

describe Efile::Md::Md502bCalculator do
  let(:intake) { create(:state_file_md_intake) }
  let!(:regular_dependent) { create(:state_file_dependent, intake: intake, dob: StateFileDependent.senior_cutoff_date + 60.years) }
  let!(:senior_dependent) { create(:state_file_dependent, intake: intake, dob: StateFileDependent.senior_cutoff_date) }
  let(:main_calculator) do
    Efile::Md::Md502Calculator.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end
  let(:instance) { main_calculator.instance_variable_get(:@md502b) }

  describe "Line 1: Regular dependent count" do
    it "returns the correct value" do
      instance.calculate
      expect(instance.lines[:MD502B_LINE_1].value).to eq(2)
    end
  end

  describe "Line 2: Over 65 dependent count" do
    it "returns the correct value" do
      instance.calculate
      expect(instance.lines[:MD502B_LINE_2].value).to eq(1)
    end
  end

  describe "Line 3: Total dependent count" do
    it "returns sums lines 1 and 2" do
      instance.calculate
      expect(instance.lines[:MD502B_LINE_3].value).to eq(3)
    end
  end
end