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
          expect(xml.at("TaxPeriodBeginDt").text).to eq "2023-01-01"
          expect(xml.at("TaxPeriodEndDt").text).to eq "2023-12-31"
        end
      end
    end
  end
end