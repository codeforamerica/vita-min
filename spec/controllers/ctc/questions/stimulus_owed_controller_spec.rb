require "rails_helper"

describe Ctc::Questions::StimulusOwedController do
  let(:intake) { create :ctc_intake }

  before do
    sign_in intake.client
  end

  describe "#update" do
    let(:params) do
      {
        ctc_stimulus_owed_form: {
          claim_owed_stimulus_money: "yes"
        }
      }
    end

    it "saves claim_owed_stimulus_money as the yes and redirects to refund-payment" do
      post :update, params: params

      expect(intake.reload.claim_owed_stimulus_money).to eq "yes"
      expect(response).to redirect_to questions_refund_payment_path
    end
  end
end
