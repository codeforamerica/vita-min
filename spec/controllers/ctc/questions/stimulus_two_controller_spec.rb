require "rails_helper"

describe Ctc::Questions::StimulusTwoController do
  let(:intake) { create :ctc_intake }

  before do
    sign_in intake.client
  end

  describe "#update" do
    it "saves 0 as the amount for stimulus 2 and redirects to the next question" do
      post :update

      expect(intake.reload.recovery_rebate_credit_amount_2).to eq 0
      expect(response).to redirect_to questions_placeholder_question_path
    end
  end
end
