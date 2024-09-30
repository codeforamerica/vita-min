require 'rails_helper'

describe Efile::Az::Az301Calculator do
  let(:intake) { create(:state_file_az_intake, :with_az321_contributions, :with_az322_contributions) }
  let(:az140_calculator) do
    Efile::Az::Az140Calculator.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end
  let(:instance) { az140_calculator.instance_variable_get(:@az301) }

  before do
    intake.charitable_cash_amount = 50
    intake.charitable_noncash_amount = 50
    intake.charitable_contributions = 'yes'
    intake.direct_file_data.filing_status = 2 # married_filing_jointly
    intake.reload
    az140_calculator.calculate
  end

  describe 'AZ301 calculations' do
    it "enters the credit for Contributions to Qualifying Charitable Organizations" do
      expect(instance.lines[:AZ301_LINE_6a].value).to eq(841)
      expect(instance.lines[:AZ301_LINE_6c].value).to eq(841)
    end

    it "enters the credit for Contributions Made or Fees Paid to Public Schools" do
      expect(instance.lines[:AZ301_LINE_7a].value).to eq(400)
      expect(instance.lines[:AZ301_LINE_7c].value).to eq(400)
    end

    it "calculates total available nonrefundable tax credits" do
      expect(instance.lines[:AZ301_LINE_26].value).to eq(1241)
    end

    it "calculates AZ301 part 2 values" do
      expect(instance.lines[:AZ301_LINE_27].value).to eq(2114) # Line 46 from AZ140
      expect(instance.lines[:AZ301_LINE_32].value).to eq(2114)
      expect(instance.lines[:AZ301_LINE_33].value).to eq(0) # Line 50 from AZ140
      expect(instance.lines[:AZ301_LINE_34].value).to eq(2114) # Difference from line 27 and 33
    end

    it "calculates Nonrefundable Tax Credits Used This Taxable Year correctly" do
      expect(instance.lines[:AZ301_LINE_40].value).to eq(841)
      expect(instance.lines[:AZ301_LINE_41].value).to eq(400)
      expect(instance.lines[:AZ301_LINE_60].value).to eq(1241)
      expect(instance.lines[:AZ301_LINE_62].value).to eq(1241)
    end
  end
end