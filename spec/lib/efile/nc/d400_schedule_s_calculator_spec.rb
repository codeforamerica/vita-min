require 'rails_helper'

describe Efile::Nc::D400ScheduleSCalculator do
  let(:intake) { create(:state_file_nc_intake) }
  let!(:d400_calculator) do
    Efile::Nc::D400Calculator.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end
  let(:instance) { d400_calculator.instance_variable_get(:@d400_schedule_s) }

  describe "Line 18: Interest Income From obligations of the United States' Possessions" do
    context "if there are no interest incomes" do
      it "returns 0" do
        d400_calculator.calculate
        expect(instance.lines[:NCD400_S_LINE_18]&.value).to eq(0)
      end
    end

    context "if there are interest incomes with interest income from obligations of US possessions" do
      let(:intake) { create :state_file_nc_intake, :df_data_1099_int }

      it "returns fed_taxable_income from federal IRS Taxable Interest Amount" do
        d400_calculator.calculate
        expect(instance.lines[:NCD400_S_LINE_18]&.value).to eq(2)
      end
    end
  end

  describe "Line 19: Taxable Portion of Social Security and Railroad Retirement Benefits" do
    context "if there are no interest incomes" do
      it "returns 0" do
        d400_calculator.calculate
        expect(instance.lines[:NCD400_S_LINE_19]&.value).to eq(0)
      end
    end

    context "if there are interest incomes with interest income from obligations of US possessions" do
      it "returns fed_taxable_income from federal IRS Taxable Interest Amount" do
        intake.direct_file_data.fed_taxable_ssb = 123
        d400_calculator.calculate
        expect(instance.lines[:NCD400_S_LINE_19]&.value).to eq(123)
      end
    end
  end

  describe 'Line 27: Exempt Income Earned or Received by a Member of a Federally Recognized Indian Tribe' do
    context "if there are not tribal wages from intake" do
      it "returns 0 for line 27 and line 41" do
        d400_calculator.calculate
        expect(instance.lines[:NCD400_S_LINE_27]&.value).to eq(0)
        expect(instance.lines[:NCD400_S_LINE_41]&.value).to eq(0)
      end
    end

    context 'if there are tribal wages from intake' do
      before do
        intake.tribal_member = "yes"
        intake.tribal_wages_amount = 500.00
      end

      it 'returns the tribal wages amount from the intake' do
        d400_calculator.calculate
        expect(instance.lines[:NCD400_S_LINE_27]&.value).to eq(500)
      end

      it 'includes the tribal wages amount in line 41' do
        d400_calculator.calculate
        expect(instance.lines[:NCD400_S_LINE_41]&.value).to eq(500)
      end
    end
  end

  describe 'Line 41: Sum of lines 17-22, 23f, 24f, 25-40' do
    before do
      # unrepresented lines are not implemented yet or OOS
      interest_report = instance_double(DirectFileJsonData::DfJsonInterestReport)
      allow(interest_report).to receive(:interest_on_government_bonds).and_return 400
      allow(intake.direct_file_json_data).to receive(:interest_reports).and_return [interest_report]

      intake.direct_file_data.fed_taxable_ssb = 400
      allow_any_instance_of(Efile::Nc::D400ScheduleSCalculator).to receive(:calculate_line_27).and_return 400
    end

    it "return sum" do
      d400_calculator.calculate
      expect(instance.lines[:NCD400_S_LINE_41].value).to eq(1200)
    end
  end
end