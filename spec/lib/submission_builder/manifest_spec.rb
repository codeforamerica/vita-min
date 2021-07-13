require "rails_helper"

describe SubmissionBuilder::Manifest do
  describe ".build" do
    before do
      allow(EnvironmentCredentials).to receive(:dig).with(:irs, :efin).and_return "123456"
    end

    let(:submission) { create :efile_submission, :ctc }
    context "when the XML is valid" do
      let(:file_double) { double }
      let(:schema_double) { double }
      let(:submission) { create :efile_submission, :ctc }

      before do
        allow(File).to receive(:open).and_return(file_double)
        allow(Nokogiri::XML).to receive(:Schema).with(file_double).and_return(schema_double)
        allow(schema_double).to receive(:validate).and_return([])
      end

      it "returns an Efile::Response object that responds to #valid? and contains no errors and provides the created Nokogiri object" do
        response = described_class.build(submission)
        expect(response).to be_an_instance_of SubmissionBuilder::Response
        expect(response).to be_valid
        expect(response.errors).to eq []
        expect(response.document).to be_an_instance_of Nokogiri::XML::Builder
      end
    end

    context "when the XML is not valid against the schema" do
      let(:file_double) { double }
      let(:schema_double) { double }
      before do
        allow(File).to receive(:open).and_return(file_double)
        allow(Nokogiri::XML).to receive(:Schema).with(file_double).and_return(schema_double)
        allow(schema_double).to receive(:validate).and_return(['error', 'error'])
      end

      it "returns an Efile::Response object that responds to #valid? and includes the Schema errors" do
        response = described_class.build(submission)
        expect(response).to be_an_instance_of SubmissionBuilder::Response
        expect(response).not_to be_valid
        expect(response.errors).to eq ['error', 'error']
        expect(response.document).to be_an_instance_of Nokogiri::XML::Builder
      end
    end

    context "the XML document contents" do
      it "includes standard information that must be sent with each submission AND information from the submission" do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        expect(xml.at("GovernmentCd").text).to eq("IRS")
        expect(xml.at("EFIN").text).to eq "123456"
        expect(xml.at("FederalSubmissionTypeCd").text).to eq "1040"
        expect(xml.at("TIN").text).to eq submission.intake.primary_ssn
        expect(xml.at("SubmissionId").text).to eq submission.irs_submission_id
      end

      it "conforms to the eFileAttachments schema" do
        expect(described_class.build(submission)).to be_valid
      end
    end
  end
end