require "rails_helper"

RSpec.describe StateFile::Questions::AzRetirementIncomeController do
  let(:intake) { create :state_file_az_intake, raw_direct_file_data: StateFile::XmlReturnSampleService.new.read("az_richard_retirement_1099r"), filing_status: filing_status }
  let(:filing_status) { 'single' }
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
    render_views

    it "does not show the spouse checkbox if single" do
      get :edit

      expect(response.body).not_to include I18n.t("state_file.questions.az_retirement_income.edit.spouse_received_pension")
    end

    context "filing status mfj" do
      let(:filing_status) { 'married_filing_jointly' }

      it "shows the spouse checkbox" do
        get :edit

        expect(response.body).to include I18n.t("state_file.questions.az_retirement_income.edit.spouse_received_pension")
      end
    end
  end

  describe "#update" do
    it_behaves_like :return_to_review_concern do
      let(:form_params) do
        {
          state_file_az_retirement_income_form: {
            received_military_retirement_payment: "yes",
            received_military_retirement_payment_amount: 100,
            primary_received_pension: "yes",
            primary_received_pension_amount: 100,
            spouse_received_pension: "yes",
            spouse_received_pension_amount: 100
          }
        }
      end
    end
  end
end