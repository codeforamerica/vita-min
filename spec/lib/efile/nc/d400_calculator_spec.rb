require 'rails_helper'

describe Efile::Nc::D400Calculator do
  let(:intake) { create(:state_file_nc_intake) }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end

  describe "Line 10b: Child Deduction" do
    [
      [["single", "married_filing_separately"], [
        [20_000, 6000],
        [30_000, 5000],
        [40_000, 4000],
        [50_000, 3000],
        [60_000, 2000],
        [70_000, 1000],
        [70_001, 0],
      ]],
      [["head_of_household"], [
        [30_000, 6000],
        [45_000, 5000],
        [60_000, 4000],
        [75_000, 3000],
        [90_000, 2000],
        [105_000, 1000],
        [105_001, 0]
      ]],
      [["married_filing_jointly", "qualifying_widow"], [
        [40_000, 6000],
        [60_000, 5000],
        [80_000, 4000],
        [100_000, 3000],
        [120_000, 2000],
        [140_000, 1000],
        [140_001, 0]
      ]]
    ].each do |filing_statuses, agis_to_deductions|
      filing_statuses.each do |filing_status|
        context "#{filing_status}" do
          let(:intake) { create(:state_file_nc_intake, filing_status: filing_status, raw_direct_file_data: StateFile::XmlReturnSampleService.new.read("nc_shiloh_hoh")) }
          let(:calculator_instance) { described_class.new(year: MultiTenantService.statefile.current_tax_year, intake: intake) }

          agis_to_deductions.each do |fagi, deduction_amount|
            it "returns the value corresponding to #{fagi} FAGI multiplied by number of QCs" do
              intake.direct_file_data.fed_agi = fagi
              intake.direct_file_data.qualifying_children_under_age_ssn_count = 2

              calculator_instance.calculate
              expect(calculator_instance.lines[:NCD400_LINE_10B].value).to eq(deduction_amount)
            end
          end
        end
      end
    end
  end

  describe "Line 20a: North Carolina Income Tax Withheld" do
    let(:intake) { create(:state_file_nc_intake, :df_data_2_w2s) }

    context "only one w2 matches primary ssn" do
      it "sums StateIncomeTaxAmt for only the matching ssn" do
        instance.calculate
        expect(instance.lines[:NCD400_LINE_20A].value).to eq(15)
      end
    end

    context "more than one w2 matches primary ssn" do
      it "sums StateIncomeTaxAmt for all matching ssn's" do
        intake.direct_file_data.w2s[1].EmployeeSSN = intake.direct_file_data.primary_ssn

        instance.calculate
        expect(instance.lines[:NCD400_LINE_20A].value).to eq(715)
      end
    end
  end

  describe "Line 20b: North Carolina Income Tax Withheld: Spouse's tax withheld" do
    let(:intake) { create(:state_file_nc_intake, :df_data_2_w2s) }

    context "only one w2 matches primary ssn" do
      it "sums StateIncomeTaxAmt for only the matching ssn" do
        intake.direct_file_data.w2s[0].EmployeeSSN = intake.direct_file_data.spouse_ssn

        instance.calculate
        expect(instance.lines[:NCD400_LINE_20B].value).to eq(15)
      end
    end

    context "more than one w2 matches primary ssn" do
      it "sums StateIncomeTaxAmt for all matching ssn's" do
        intake.direct_file_data.w2s.each { |w2| w2.EmployeeSSN = intake.direct_file_data.spouse_ssn }

        instance.calculate
        expect(instance.lines[:NCD400_LINE_20B].value).to eq(715)
      end
    end
  end

  describe "Line 23: Add Lines 20a through 22" do
    it "adds the other lines" do
      allow(instance).to receive(:calculate_line_20a).and_return 5
      allow(instance).to receive(:calculate_line_20b).and_return 5

      instance.calculate
      expect(instance.lines[:NCD400_LINE_23].value).to eq(10)
    end
  end
end