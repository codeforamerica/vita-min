require "rails_helper"

describe Ctc::Questions::StimulusOneReceivedController do
  let(:intake) { create :ctc_intake }

  before do
    sign_in intake.client
  end

  describe "#update" do
    context "with no answer" do
      let(:params) do
        {
          ctc_stimulus_one_received_form: {
            eip_one: nil
          }
        }
      end

      it "re-renders the form with errors" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors[:eip_one]).to include "Can't be blank."
        expect(intake.eip_one).to eq nil
      end
    end

    context "with an invalid answer" do
      let(:params) do
        {
          ctc_stimulus_one_received_form: {
            eip_one: "i am not a number"
          }
        }
      end

      it "re-renders the form with errors" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors[:eip_one]).to include "is not a number"
        expect(intake.eip_one).to eq nil
      end
    end

    context "with a valid answer" do
      let(:params) do
        {
          ctc_stimulus_one_received_form: {
            eip_one: 100
          }
        }
      end

      it "saves eip_one value and moves to the next question" do
        post :update, params: params

        expect(intake.reload.eip_one).to eq 100
        expect(response).to redirect_to questions_placeholder_question_path
      end
    end
  end
end
