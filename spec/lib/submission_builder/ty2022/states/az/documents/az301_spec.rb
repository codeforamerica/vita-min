require 'rails_helper'

describe SubmissionBuilder::Ty2022::States::Az::Documents::Az301, required_schema: "az" do
  describe ".document" do
    let(:intake) { create(:state_file_az_intake) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission.reload, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    context "with AZ-321 contributions" do
      let(:intake) { create(:state_file_az_intake, :with_az321_contributions) }

      it "generates XML with correct AZ-321 contribution information" do
        expect(xml.at("NonRfndTaxCr ColumnA CtrbChrtyPrvdAstWrkgPor").text).to eq "421"
        expect(xml.at("NonRfndTaxCr ColumnC CtrbChrtyPrvdAstWrkgPor").text).to eq "421"
      end
    end

    context "with AZ-322 contributions" do
      let(:intake) { create(:state_file_az_intake, :with_az322_contributions) }

      it "generates XML with correct AZ-322 contribution information" do
        expect(xml.at("NonRfndTaxCr ColumnA CtrbMdFePdPblcSchl").text).to eq "200"
        expect(xml.at("NonRfndTaxCr ColumnC CtrbMdFePdPblcSchl").text).to eq "200"
      end
    end

    context "with both AZ-321 and AZ-322 contributions" do
      let(:intake) { create(:state_file_az_intake, :with_az321_contributions, :with_az322_contributions) }

      it "generates XML with correct total available tax credit" do
        expect(xml.at("NonRfndTaxCr ColumnC TotalAvailTaxCr").text).to eq "621"
        expect(xml.at("AppTaxCr ComputedTax").text).to eq "2461"
        expect(xml.at("AppTaxCr FamilyIncomeTax").text).to eq "0"
        expect(xml.at("AppTaxCr NonrefunCreditsUsed CtrbChrtyPrvdAstWrkgPor").text).to eq "421"
        expect(xml.at("AppTaxCr NonrefunCreditsUsed CtrbMdFePdPblcSchl").text).to eq "200"
        expect(xml.at("AppTaxCr TxCrUsedForm301").text).to eq "621"
        expect(xml.at("AppTaxCr TotalAvailTaxCrClm").text).to eq "621"
      end
    end
  end
end