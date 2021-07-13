require "rails_helper"

describe SubmissionBuilder::Documents::AdvCtcIrs1040 do
  describe ".build" do
    before do
      allow(EnvironmentCredentials).to receive(:dig).with(:irs, :efin).and_return "123456"
      dependent = submission.intake.dependents.first
      dependent.update(first_name: "Keeley", birth_date: Date.new(2020, 1, 1), relationship: "daughter", ssn: "123001234")
      dependent2 = submission.intake.dependents.second
      dependent2.update(first_name: "Kyle", birth_date: Date.new(1975, 1, 1), relationship: "son", ssn: "123001235")
      dependent3 = submission.intake.dependents.third
      dependent3.update(first_name: "Kelly", birth_date: Date.new(2019, 1, 1), relationship: "stepchild", ssn: "123001236")
    end


    let(:submission) { create :efile_submission, :ctc, filing_status: filing_status, tax_year: 2020 }

    let(:filing_status) { "married_filing_jointly" }

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
        expect(response.document).to be_an_instance_of Nokogiri::XML::Document
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
        expect(response.document).to be_an_instance_of Nokogiri::XML::Document
      end
    end

    context "the XML document contents" do
      it "includes required nodes on the IRS1040 for the AdvCTC revenue procedure" do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        expect(xml.at("IndividualReturnFilingStatusCd").text).to eq "2" # code for marrying filing joint
        expect(xml.at("VirtualCurAcquiredDurTYInd").text).to eq "false"
        dependent_nodes = xml.search("DependentDetail")
        expect(dependent_nodes.length).to eq 3
        expect(dependent_nodes[0].at("DependentFirstNm").text).to eq "Keeley"
        expect(dependent_nodes[0].at("DependentLastNm").text).to eq "Kiwi"
        expect(dependent_nodes[0].at("DependentNameControlTxt").text).to eq "KIWI"
        expect(dependent_nodes[0].at("DependentSSN").text).to eq "123001234"
        expect(dependent_nodes[0].at("DependentRelationshipCd").text).to eq "DAUGHTER"
        expect(dependent_nodes[0].at("EligibleForChildTaxCreditInd").text).to eq "X"
        expect(dependent_nodes[1].at("DependentFirstNm").text).to eq "Kyle"
        expect(dependent_nodes[1].at("DependentLastNm").text).to eq "Kiwi"
        expect(dependent_nodes[1].at("DependentNameControlTxt").text).to eq "KIWI"
        expect(dependent_nodes[1].at("DependentSSN").text).to eq "123001235"
        expect(dependent_nodes[1].at("DependentRelationshipCd").text).to eq "SON"
        expect(dependent_nodes[1].at("EligibleForChildTaxCreditInd")).to be_nil
        expect(dependent_nodes[2].at("DependentFirstNm").text).to eq "Kelly"
        expect(dependent_nodes[2].at("DependentLastNm").text).to eq "Kiwi"
        expect(dependent_nodes[2].at("DependentNameControlTxt").text).to eq "KIWI"
        expect(dependent_nodes[2].at("DependentSSN").text).to eq "123001236"
        expect(dependent_nodes[2].at("DependentRelationshipCd").text).to eq "STEPCHILD"
        expect(dependent_nodes[2].at("EligibleForChildTaxCreditInd").text).to eq "X"
      end

      it "conforms to the eFileAttachments schema" do
        expect(described_class.build(submission)).to be_valid
      end
    end
  end
end