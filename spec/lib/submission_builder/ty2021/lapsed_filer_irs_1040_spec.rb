require "rails_helper"

describe SubmissionBuilder::TY2021::LapsedFilerIrs1040 do
  describe ".build" do

    around do |example|
      ENV["TEST_SCHEMA_VALIDITY_ONLY"] = 'true'
      example.run
      ENV.delete("TEST_SCHEMA_VALIDITY_ONLY")
    end

    before do
      submission.intake.update(primary_last_name: "Kòala")
      dependent = submission.intake.dependents.first
      dependent_attrs = attributes_for(:qualifying_child, first_name: "Keeley Elizabeth Aurora", last_name: "Kiwi-Cucumbersteiningham", birth_date: Date.new(2020, 1, 1), relationship: "daughter", ssn: "123001234")
      dependent.update(dependent_attrs)
      dependent2 = submission.intake.dependents.second
      dependent2_attrs = attributes_for(:qualifying_child, birth_date: Date.new(1975, 1, 1), relationship: "son", ssn: "123001235") # too old to be qualifying child
      dependent2.update(dependent2_attrs)
      dependent3 = submission.intake.dependents.third
      dependent3_attrs = attributes_for(:qualifying_relative, first_name: "Kelly", birth_date: Date.new(1960, 1, 1), relationship: "parent", ssn: "123001236")
      dependent3.update(dependent3_attrs)
      EfileSubmissionDependent.create_qualifying_dependent(submission, dependent)
      EfileSubmissionDependent.create_qualifying_dependent(submission, dependent2)
      EfileSubmissionDependent.create_qualifying_dependent(submission, dependent3)
      submission.reload
    end

    let(:submission) { create :efile_submission, :ctc, filing_status: "married_filing_jointly", tax_year: 2021 }

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
      before do
        create(:bank_account, intake: submission.intake)
        submission.intake.update(refund_payment_method: "direct_deposit")
      end

      it "includes required nodes on the IRS1040 for the AdvCTC revenue procedure" do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        expect(xml.at("IndividualReturnFilingStatusCd").text).to eq "2" # code for marrying filing joint
        expect(xml.at("VirtualCurAcquiredDurTYInd").text).to eq "false"
        expect(xml.at("TotalExemptPrimaryAndSpouseCnt").text).to eq "2" # married filing joint
        dependent_nodes = xml.search("DependentDetail")
        expect(dependent_nodes.length).to eq 2
        expect(dependent_nodes[0].at("DependentFirstNm").text).to eq "Keeley Elizabeth Aur"
        expect(dependent_nodes[0].at("DependentFirstNm").text.length).to eq 20
        expect(dependent_nodes[0].at("DependentLastNm").text).to eq "Kiwi-Cucumbersteinin"
        expect(dependent_nodes[0].at("DependentFirstNm").text.length).to eq 20
        expect(dependent_nodes[0].at("DependentNameControlTxt").text).to eq "KIWI"
        expect(dependent_nodes[0].at("DependentSSN").text).to eq "123001234"
        expect(dependent_nodes[0].at("DependentRelationshipCd").text).to eq "DAUGHTER"
        expect(dependent_nodes[0].at("EligibleForChildTaxCreditInd").text).to eq "X"
        expect(dependent_nodes[1].at("DependentFirstNm").text).to eq "Kelly"
        expect(dependent_nodes[1].at("DependentLastNm").text).to eq "Kiwi"
        expect(dependent_nodes[1].at("DependentNameControlTxt").text).to eq "KIWI"
        expect(dependent_nodes[1].at("DependentSSN").text).to eq "123001236"
        expect(dependent_nodes[1].at("DependentRelationshipCd").text).to eq "PARENT"
        expect(dependent_nodes[1].at("EligibleForChildTaxCreditInd")).to be_nil
        expect(xml.at("ChldWhoLivedWithYouCnt").text).to eq "1"
        expect(xml.at("OtherDependentsListedCnt").text).to eq "1"
        expect(xml.at("TotalItemizedOrStandardDedAmt").text).to eq "25100"
        expect(xml.at("TotDedCharitableContriAmt").text).to eq "25100"
        expect(xml.at("TotalDeductionsAmt").text).to eq "25100"
        expect(xml.at("TaxableIncomeAmt").text).to eq "0"

        # Line 28: remaining amount of CTC they are claiming (as determined in flow and listed on 8812 14i
        expect(xml.at("RefundableCTCOrACTCAmt").text).to eq "0" # TODO: replace this when we calculate this number

        expect(xml.at("RecoveryRebateCreditAmt").text).to eq "3200" # Line 30

        # Line 32, 33, 34, 35a: Line 28 + Line 30
        expect(xml.at("RefundableCreditsAmt").text).to eq "3200"
        expect(xml.at("TotalPaymentsAmt").text).to eq "3200"
        expect(xml.at("OverpaidAmt").text).to eq "3200"
        expect(xml.at("RefundAmt").text).to eq "3200"

        expect(xml.at("RoutingTransitNum").text).to eq "123456789"
        expect(xml.at("BankAccountTypeCd").text).to eq "1"
        expect(xml.at("DepositorAccountNum").text).to eq "87654321"
        expect(xml.at("RefundProductCd").text).to eq "NO FINANCIAL PRODUCT"
      end

      it "conforms to the eFileAttachments schema" do
        expect(described_class.build(submission)).to be_valid
      end
    end

    context "when not claiming additional rrc credit" do
      before do
        submission.intake.update(claim_owed_stimulus_money: "no")
      end

      it "sets the credit amounts to 0, and sets refund amount to 0" do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)

        expect(xml.at("RecoveryRebateCreditAmt").text).to eq "0"
        expect(xml.at("RecoveryRebateCreditAmt").text).to eq "0"
        expect(xml.at("RefundAmt").text).to eq "0"
      end

      it "conforms to the eFileAttachments schema" do
        expect(described_class.build(submission)).to be_valid
      end
    end
  end
end
