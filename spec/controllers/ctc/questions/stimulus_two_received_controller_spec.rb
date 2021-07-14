require "rails_helper"

describe Ctc::Questions::StimulusTwoReceivedController do
  let(:intake) { create :ctc_intake }

  before do
    sign_in intake.client
  end

  describe "#update" do
    context "with no answer" do
      let(:params) do
        {
          ctc_stimulus_two_received_form: {
            recovery_rebate_credit_amount_2: nil
          }
        }
      end

      it "re-renders the form with errors" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors[:recovery_rebate_credit_amount_2]).to include "Can't be blank."
        expect(intake.recovery_rebate_credit_amount_2).to eq nil
      end
    end

    context "with an invalid answer" do
      let(:params) do
        {
          ctc_stimulus_two_received_form: {
            recovery_rebate_credit_amount_2: "i am not a number"
          }
        }
      end

      it "re-renders the form with errors" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors[:recovery_rebate_credit_amount_2]).to include "is not a number"
        expect(intake.recovery_rebate_credit_amount_2).to eq nil
      end
    end

    context "with a valid answer" do
      let(:params) do
        {
          ctc_stimulus_two_received_form: {
            recovery_rebate_credit_amount_2: 100
          }
        }
      end

      it "saves recovery_rebate_credit_amount_2 value and moves to the stimulus-received" do
        post :update, params: params

        expect(intake.reload.recovery_rebate_credit_amount_2).to eq 100
        expect(response).to redirect_to questions_stimulus_received_path
      end
    end
  end
end
