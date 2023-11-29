require "rails_helper"

RSpec.describe StateFile::Questions::DataTransferOffboardingController do
  describe "#edit" do
    let(:intake) { create :state_file_az_intake }

    context "when the client's Direct File data disqualifies them" do
      before do
        session[:state_file_intake] = intake.to_global_id
        allow(subject).to receive(:params).and_return({us_state: 'az'})
        # TODO: Why can't I set this directly by saying `intake.direct_file_data.filing_status = 3`?
        allow_any_instance_of(DirectFileData).to receive(:filing_status).and_return(3)
      end

      it "gets the correct values for ineligible_reason" do
        expect(subject.ineligible_reason).to eq(I18n.t('state_file.questions.data_transfer_offboarding.edit.ineligible_reason.married_filing_separately'))
      end
    end

    context "when the client is eligible" do
      before do
        session[:state_file_intake] = intake.to_global_id
        allow(subject).to receive(:params).and_return({us_state: 'az'})
      end

      it "gets the correct values for ineligible_reason" do
        expect(subject.ineligible_reason).to be_nil
      end
    end
  end
end
