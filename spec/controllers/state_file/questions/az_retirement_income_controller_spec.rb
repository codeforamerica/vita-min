require "rails_helper"

RSpec.describe StateFile::Questions::AzRetirementIncomeController do
  let(:intake) { create :state_file_az_intake, raw_direct_file_data: StateFile::XmlReturnSampleService.new.read("az_richard_retirement_1099r") }
  before do
    sign_in intake
  end

  describe ".show?" do
    it "returns true if they have a 1099R and TotalTaxablePensionsAmt is > 0" do
      expect(described_class.show?(intake)).to eq true
    end

    it "returns false when TotalTaxablePensionsAmt is 0" do
      intake.direct_file_data.fed_taxable_pensions = 0
      expect(described_class.show?(intake)).to eq false
    end

    it "returns false if 1099R missing" do
      intake = create :state_file_az_intake, raw_direct_file_data: StateFile::XmlReturnSampleService.new.read("az_unemployment")
      sign_in intake
      expect(described_class.show?(intake)).to eq false
    end
  end

  describe "#edit" do
  # TODO: test that only mfj sees the spouse checkbox
  end

  describe "#update" do
    it_behaves_like :return_to_review_concern do
      let(:form_params) do
        {
          state_file_az_retirement_income_form: {
          #  TODO: add actual params
          }
        }
      end
    end
  end
end