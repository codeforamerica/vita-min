require "rails_helper"

describe Ctc::Questions::StimulusTwoController do
  let(:intake) { create :ctc_intake }

  before do
    sign_in intake.client
  end

  describe "#update" do
    it "saves 0 as the amount for stimulus 2 and redirects to the stimulus-received" do
      post :update

      expect(intake.reload.eip2_amount_received).to eq 0
      expect(response).to redirect_to questions_stimulus_received_path
    end
  end
end
