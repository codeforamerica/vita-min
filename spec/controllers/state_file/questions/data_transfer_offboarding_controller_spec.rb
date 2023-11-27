require "rails_helper"

RSpec.describe StateFile::Questions::DataTransferOffboardingController do
  describe "#edit" do
    let(:intake) { create :state_file_az_intake }

    context "when the client is ineligible" do
      before do
        session[:state_file_intake] = intake.to_global_id
        allow(subject).to receive(:params).and_return({us_state: 'az'})
        allow_any_instance_of(StateFileAzIntake).to receive(:disqualifying_eligibility_answer).and_return(:eligibility_lived_in_state)
      end

      it "gets the correct values for ineligible_reason" do
        expect(subject.ineligible_reason).to eq('did not live in Arizona for all of 2023')
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
