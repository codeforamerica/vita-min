require 'rails_helper'

describe Efile::Nc::D400Calculator do
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
end