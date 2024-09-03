require 'rails_helper'

describe Efile::Nc::D400Calculator do
  let(:intake) { create(:state_file_nc_intake) }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
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