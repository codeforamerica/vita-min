require "rails_helper"

describe Ctc::Questions::StimulusPaymentsController do
  let(:intake) { create :ctc_intake }

  before do
    sign_in intake.client
  end

  describe "#update" do
    it "resets eip1_amount_received and eip2_amount_received to nil and redirects to /stimulus-received" do
      post :update

      expect(intake.reload.eip1_amount_received).to be_nil
      expect(intake.reload.eip2_amount_received).to be_nil
      expect(response).to redirect_to questions_stimulus_received_path
    end
  end
end
