require 'rails_helper'

describe SubmissionBuilder::Ty2022::States::Ny::IndividualReturn do
  describe '.build' do
    let(:intake) { create(:state_file_ny_intake, filing_status: filing_status) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let!(:initial_efile_device_info) { create :state_file_efile_device_info, :initial_creation, :filled, intake: intake }
    let!(:submission_efile_device_info) { create :state_file_efile_device_info, :submission, :filled, intake: intake }

    context "when single" do
      let(:filing_status) { 'single' }

      it 'generates XML from the database models' do
        xml = described_class.build(submission).document
        expect(xml.at("tiPrime FIRST_NAME").text).to eq(intake.primary.first_name)
        expect(xml.at("tiSpouse")).to be_nil
      end
    end

    context "when married" do
      let(:intake) { create(:state_file_ny_intake, :mfj_with_complete_spouse) }

      it 'generates XML from the database models' do
        xml = described_class.build(submission).document
        # TODO: where do we put spouse birth date? Filling SP_DOB_DT causes an error
        # expect(xml.at("rtnHeader SP_DOB_DT").text).to eq intake.spouse.birth_date.strftime("%m%d%Y")
        expect(xml.at("tiSpouse FIRST_NAME").text).to eq(intake.spouse.first_name)
        expect(xml.at("tiSpouse MI_NAME").text).to eq(intake.spouse.middle_initial)
        expect(xml.at("tiSpouse LAST_NAME").text).to eq(intake.spouse.last_name)
        expect(xml.at("tiSpouse SP_SSN_NMBR").text).to eq(intake.spouse.ssn)
        expect(xml.at("tiSpouse SP_EMP_DESC").text).to eq(intake.direct_file_data.spouse_occupation)
      end
    end

    context "when claiming the federal EIC" do
      let(:intake) { create(:state_file_zeus_intake) }

      it 'includes the IT215 document and EIC dependents' do
        xml = described_class.build(submission).document
        expect(xml.at("IT215")).to be_present
        dependent_nodes = xml.search("dependent")
        eic_dependent_nodes = dependent_nodes.select { |n| n.at("DEP_FORM_ID").text == "215" }
        expect(eic_dependent_nodes.length).to eq 3
      end
    end

    context "when claiming the federal CTC" do
      let(:intake) { create(:state_file_zeus_intake) }

      it 'includes the IT213 document and CTC dependents' do
        xml = described_class.build(submission).document
        expect(xml.at("IT213")).to be_present
        dependent_nodes = xml.search("dependent")
        ctc_dependent_nodes = dependent_nodes.select { |n| n.at("DEP_FORM_ID").text == "348" }
        expect(ctc_dependent_nodes.length).to eq 3
      end
    end

    context "when getting a refund to a personal checking account" do
      let(:intake) { create(:state_file_ny_intake, filing_status: filing_status, routing_number: "011234567", account_number: "123456789", account_type: 1) }
      let(:filing_status) { 'single' }

      it 'generates XML from the database models' do
        xml = described_class.build(submission).document
        expect(xml.at("rtnHeader ABA_NMBR").attribute('claimed').value).to eq(intake.routing_number)
        expect(xml.at("rtnHeader BANK_ACCT_NMBR").attribute('claimed').value).to eq(intake.account_number)
        expect(xml.at("rtnHeader ACCT_TYPE_CD").attribute('claimed').value).to eq("1")
      end
    end

    context 'Yonkers' do
      let(:intake) { create(:state_file_ny_intake) }
      let(:filing_status) { 'single' }

      it 'just says no to Yonkers' do
        xml = described_class.build(submission).document
        expect(xml.at("YNK_WRK_LVNG_IND")["claimed"]).to eq("2")
      end
    end

    context "when there are w2s present" do
      let(:intake) { create(:state_file_ny_intake) }
      let(:filing_status) { 'single' }

      it "w2s are copied from the intake" do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        expect(xml.css('IRSW2').count).to eq 1
        expect(xml.at("IRSW2 EmployeeSSN").text).to eq "555002222"
      end
    end

    context "when there are more than 7 dependents" do
      let(:intake) { create(:state_file_zeus_intake) }
      #let(:intake) { create(:state_file_ny_intake) }
      let(:filing_status) { 'single' }

      it "creates an additional dependents pdf" do
        submission_builder = SubmissionBuilder::Ty2022::States::Ny::IndividualReturn.new(submission)
        additional_dependents = submission_builder.pdf_documents.select do |d|
          d.pdf == PdfFiller::AdditionalDependentsPdf
        end
        expect(additional_dependents.present?).to eq true
      end
    end
  end
end