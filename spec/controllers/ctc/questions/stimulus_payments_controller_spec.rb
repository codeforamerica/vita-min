require "rails_helper"

describe Ctc::Questions::StimulusPaymentsController do
  let(:intake) { create :ctc_intake }

  before do
    sign_in intake.client
  end

  describe "#update" do
    it "resets recovery_rebate_credit_amount_1 and recovery_rebate_credit_amount_2 to nil and redirects to /stimulus-received" do
      post :update

      expect(intake.reload.recovery_rebate_credit_amount_1).to be_nil
      expect(intake.reload.recovery_rebate_credit_amount_2).to be_nil
      expect(response).to redirect_to questions_stimulus_received_path
    end
  end
end
