require "rails_helper"

RSpec.describe StateFile::Questions::DataTransferOffboardingController do
  describe "#edit" do
    let(:intake) { create :state_file_az_intake, filing_status: filing_status }
    let(:filing_status) { :single }

    before do
      sign_in intake
    end

    context "when the client's Direct File data disqualifies them" do
      let(:filing_status) { :married_filing_separately }

      it "gets the correct values for ineligible_reason" do
        expect(subject.ineligible_reason).to eq(I18n.t('state_file.questions.data_transfer_offboarding.edit.ineligible_reason.married_filing_separately'))
      end
    end

    context "when the client is eligible" do
      it "gets the correct values for ineligible_reason" do
        expect(subject.ineligible_reason).to be_nil
      end
    end
  end
end
