require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Id::Documents::Id40, required_schema: "id" do
  describe ".document" do
    let(:intake) { create(:state_file_id_intake, filing_status: "single") }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    context "single filer" do
      let(:intake) { create(:state_file_id_intake, filing_status: "single") }

      it "correctly fills answers" do
        expect(xml.at("FilingStatus").text).to eq "SINGLE"
      end
    end

    context "married filing jointly" do
      let(:intake) { create(:state_file_id_intake, filing_status: "married_filing_jointly") }

      it "correctly fills answers" do
        expect(xml.at("FilingStatus").text).to eq "JOINT"
      end
    end

    context "married filing separately" do
      let(:intake) { create(:state_file_id_intake, filing_status: "married_filing_separately") }

      it "correctly fills answers" do
        expect(xml.at("FilingStatus").text).to eq "SEPART"
      end
    end

    context "head of household with dependents" do
      let(:intake) { create(:state_file_id_intake, :with_dependents, filing_status: "head_of_household") }

      it "correctly fills answers" do
        intake.reload
        expect(xml.at("FilingStatus").text).to eq "HOH"
        # expect(xml.css('DependentGrid').count).to eq 3
        #
        # expect(xml.document.at("DependentGrid[1]/DependentFirstName").text).to eq "Gloria"
        # expect(xml.document.at("DependentGrid[1]/DependentLastName").text).to eq "Hemingway"
        # expect(xml.document.at("DependentGrid[1]/DependentDOB").text).to eq "1920-01-01"
        #
        # expect(xml.document.at("DependentGrid[2]/DependentFirstName").text).to eq "Patrick"
        # expect(xml.document.at("DependentGrid[2]/DependentLastName").text).to eq "Hemingway"
        # expect(xml.document.at("DependentGrid[2]/DependentDOB").text).to eq "1919-01-01"
        #
        # expect(xml.document.at("DependentGrid[3]/DependentFirstName").text).to eq "Jack"
        # expect(xml.document.at("DependentGrid[3]/DependentLastName").text).to eq "Hemingway"
        # expect(xml.document.at("DependentGrid[3]/DependentDOB").text).to eq "1919-01-01"
      end
    end

    context "qualifying widow" do
      let(:intake) { create(:state_file_id_intake, filing_status: "qualifying_widow") }

      it "correctly fills answers" do
        expect(xml.at("FilingStatus").text).to eq "QWID"
      end
    end
  end
end