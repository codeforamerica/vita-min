require 'rails_helper'

describe Efile::Nc::D400ScheduleSCalculator do
  let!(:force_load) { Efile::Nc::NcD400ScheduleS }
  let(:output) { Graph::Graph.evaluate(input)[:nc_d400_schedule_s] }
  let(:input) { { interest_reports: [], state_file_1099_rs: [] } }

  describe "Line 18: Interest Income From obligations of the United States' Possessions" do
    context "if there are no interest incomes" do
      let(:input) { { interest_reports: [] } }

      it "returns 0" do
        expect(output[:line_18]).to eq(0)
      end
    end

    context "if there are interest incomes with interest income from obligations of US possessions" do
      let(:input) { { interest_reports: [{ interest_on_government_bonds: 5000 }] } }

      it "returns fed_taxable_income from federal IRS Taxable Interest Amount" do
        expect(output[:line_18]).to eq(5000)
      end
    end
  end

  describe "Line 19: Taxable Portion of Social Security and Railroad Retirement Benefits" do
    context "if there are no interest incomes" do
      let(:input) { {} }

      it "returns 0" do
        expect(output[:line_19]).to eq(0)
      end
    end

    context "if there are interest incomes with interest income from obligations of US possessions" do
      let(:input) { { fed_taxable_ssb: 123 } }

      it "returns fed_taxable_income from federal IRS Taxable Interest Amount" do
        expect(output[:line_19]).to eq(123)
      end
    end
  end

  describe "Line 20: Bailey Retirement Benefit" do
    let(:input) {
      {
        state_file_1099_rs:
          [
            {
              income_source: :bailey_settlement,
              bailey_settlement_at_least_five_years: false,
              bailey_settlement_from_retirement_plan: true,
              taxable_amount: 1000
            },
            {
              income_source: :bailey_settlement,
              bailey_settlement_at_least_five_years: true,
              bailey_settlement_from_retirement_plan: false,
              taxable_amount: 1000
            },
            {
              income_source: :bailey_settlement,
              bailey_settlement_at_least_five_years: false,
              bailey_settlement_from_retirement_plan: false,
              taxable_amount: 1000
            },
            {
              income_source: :other,
              bailey_settlement_at_least_five_years: false,
              bailey_settlement_from_retirement_plan: true,
              taxable_amount: 1000
            },
          ]
      }
    }

    it "adds up the taxable income amounts from df 1099Rs from Bailey Settlement" do
      expect(output[:line_20]).to eq(2000)
    end
  end

  describe "Line 21: Retirement Uniformed Services" do
    let(:input) {
      {
        state_file_1099_rs:
          [
            {
              income_source: :uniformed_services,
              uniformed_services_retired: false,
              uniformed_services_qualifying_plan: true,
              taxable_amount: 1000
            },
            {
              income_source: :uniformed_services,
              uniformed_services_retired: true,
              uniformed_services_qualifying_plan: false,
              taxable_amount: 1000
            },
            {
              income_source: :uniformed_services,
              uniformed_services_retired: false,
              uniformed_services_qualifying_plan: false,
              taxable_amount: 1000
            },
            {
              income_source: :other,
              uniformed_services_retired: false,
              uniformed_services_qualifying_plan: true,
              taxable_amount: 1000
            },
          ]
      }
    }

    it "adds up the taxable income amounts from df 1099Rs from Uniformed Services" do
      expect(output[:line_21]).to eq(2000)
    end
  end

  describe 'Line 27: Exempt Income Earned or Received by a Member of a Federally Recognized Indian Tribe' do
    context "if there are not tribal wages from intake" do
      it "returns 0 for line 27 and line 41" do
        expect(output[:line_27]).to eq(0)
        expect(output[:line_41]).to eq(0)
      end
    end

    context 'if there are tribal wages from intake' do
      let(:input) { { interest_reports: [], state_file_1099_rs: [], tribal_wages_amount: 500 } }

      it 'returns the tribal wages amount from the intake' do
        expect(output[:line_27]).to eq(500)
      end

      it 'includes the tribal wages amount in line 41' do
        expect(output[:line_41]).to eq(500)
      end
    end
  end

  describe 'Line 41: Sum of lines 17-22, 23f, 24f, 25-40' do
    let(:input) {
      { interest_reports: [{ interest_on_government_bonds: 400 }], state_file_1099_rs: [], fed_taxable_ssb: 400 }
    }
    let!(:nc_d400_schedule_s_stubs) do
      class NcD400ScheduleSStubs < Graph::Graph
        def self.module_name = :nc_d400_schedule_s
        constant(:line_20) { 200 }
        constant(:line_21) { 100 }
        constant(:line_27) { 400 }
      end
    end

    it "return sum" do
      expect(output[:line_41]).to eq(1500)
    end
  end
end