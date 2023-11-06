require 'rails_helper'

describe SubmissionBuilder::Ty2022::States::Ny::IndividualReturn do
  describe '.build' do
    let(:intake) { create(:state_file_ny_intake, filing_status: filing_status) }
    let(:submission) { create(:efile_submission, data_source: intake) }

    context "when single" do
      let(:filing_status) { 'single' }

      it 'generates XML from the database models' do
        xml = described_class.build(submission).document
        expect(xml.at("tiPrime FIRST_NAME").text).to eq(intake.primary.first_name)
        expect(xml.at("tiSpouse")).to be_nil
      end
    end

    context "when married" do
      let(:intake) { create(:state_file_ny_intake, filing_status: filing_status, spouse_first_name: "Goose") }
      let(:filing_status) { 'married_filing_jointly' }

      it 'generates XML from the database models' do
        xml = described_class.build(submission).document
        expect(xml.at("tiSpouse FIRST_NAME").text).to eq(intake.spouse.first_name)
      end
    end

    context "when claiming the state EIC" do
      let(:intake) { create(:state_file_ny_intake, filing_status: filing_status, spouse_first_name: "Goose", dependents: [create(:state_file_dependent, eic_qualifying: true)]) }
      let(:filing_status) { 'married_filing_jointly' }

      it 'includes the IT215 document and EIC dependents' do
        xml = described_class.build(submission).document
        expect(xml.at("dependent DEP_CHLD_FRST_NAME").text).to eq(intake.dependents.first.first_name)
        expect(xml.at("IT215 E_FED_EITC_IND").attribute('claimed').value).to eq("1")
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

  end
end