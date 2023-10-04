require 'rails_helper'

describe SubmissionBuilder::Ty2022::States::Ny::IndividualReturn do
  describe '.build' do
    let(:intake) { create(:state_file_ny_intake, filing_status: filing_status) }
    let(:submission) { create(:efile_submission, data_source: intake) }

    context "when single" do
      let(:filing_status) { 'single' }

      it 'generates XML from the database models' do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        expect(xml.at("tiPrime FIRST_NAME").text).to eq(intake.primary.first_name)
        expect(xml.at("tiSpouse")).to be_nil
      end
    end

    context "when married" do
      let(:intake) { create(:state_file_ny_intake, filing_status: filing_status, spouse_first_name: "Goose") }
      let(:filing_status) { 'married_filing_jointly' }

      it 'generates XML from the database models' do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        expect(xml.at("tiSpouse FIRST_NAME").text).to eq(intake.spouse.first_name)
      end
    end

    context "when claiming the state EIC"do
      let(:intake) { create(:state_file_ny_intake, filing_status: filing_status, spouse_first_name: "Goose") }
      let(:filing_status) { 'married_filing_jointly' }

      it 'includes the IT215 document' do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        expect(xml.at("IT215 E_FED_EITC_IND").attribute('claimed').value).to eq("1")
      end
    end
  end
end