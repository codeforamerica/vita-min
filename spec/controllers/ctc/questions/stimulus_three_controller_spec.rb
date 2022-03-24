require "rails_helper"

describe Ctc::Questions::StimulusThreeController do
  let(:intake) { create :ctc_intake }

  before do
    sign_in intake.client
  end

  describe "#update" do
    it "saves 0 as the amount for stimulus 1 and redirects to stimulus two" do
      post :update, params: {
        ctc_stimulus_three_form: {
          eip13entry_method: 'did_not_receive',
        }
      }

      expect(intake.reload.eip3_amount_received).to eq 0
      expect(response).to redirect_to questions_stimulus_three_path
    end
  end
end
