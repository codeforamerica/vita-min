require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Md::Documents::Md502, required_schema: "md" do
  describe ".document" do
    let(:intake) { create(:state_file_md_intake, filing_status: "single") }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    it "generates a valid xml" do
      expect(build_response.errors).to be_empty
    end

    describe ".document" do
      context "single filer" do
        it "correctly fills answers" do
          expect(xml.document.at('ResidencyStatusPrimary')&.text).to eq "true"
          expect(xml.document.at("TaxPeriodBeginDt").text).to eq "2023-01-01"
          expect(xml.document.at("TaxPeriodEndDt").text).to eq "2023-12-31"
          expect(xml.document.at('FilingStatus')&.text).to eq "Single"
          expect(xml.document.at('DaytimePhoneNumber')&.text).to eq "5551234567"
        end
      end

      context "mfj filer" do
        let(:intake) { create(:state_file_md_intake, filing_status: "married_filing_jointly") }
        it "correctly fills answers" do
          expect(xml.document.at('FilingStatus')&.text).to eq "Joint"
        end
      end

      context "mfs filer" do
        let(:intake) { create(:state_file_md_intake, filing_status: "married_filing_separately") }
        it "correctly fills answers" do
          expect(xml.document.at('FilingStatus')&.text).to eq "MarriedFilingSeparately"
        end
      end

      context "hoh filer" do
        let(:intake) { create(:state_file_md_intake, filing_status: "head_of_household") }

        it "correctly fills answers" do
          expect(xml.document.at('FilingStatus')&.text).to eq "HeadOfHousehold"
        end
      end

      context "qw filer" do
        let(:intake) { create(:state_file_md_intake, filing_status: "qualifying_widow") }
        it "correctly fills answers" do
          expect(xml.document.at('FilingStatus')&.text).to eq "QualifyingWidow"
        end
      end

      context "dependent filer" do
        let(:intake) { create(:state_file_md_intake, :claimed_as_dependent) }

        it "correctly fills answers" do
          expect(xml.document.at('FilingStatus')&.text).to eq "DependentTaxpayer"
        end
      end
    end
  end
end