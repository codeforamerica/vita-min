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
            eip_two: nil
          }
        }
      end

      it "re-renders the form with errors" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors[:eip_two]).to include "Can't be blank."
        expect(intake.eip_two).to eq nil
      end
    end

    context "with an invalid answer" do
      let(:params) do
        {
          ctc_stimulus_two_received_form: {
            eip_two: "i am not a number"
          }
        }
      end

      it "re-renders the form with errors" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors[:eip_two]).to include "is not a number"
        expect(intake.eip_two).to eq nil
      end
    end

    context "with a valid answer" do
      let(:params) do
        {
          ctc_stimulus_two_received_form: {
            eip_two: 100
          }
        }
      end

      it "saves eip_two value and moves to the next question" do
        post :update, params: params

        expect(intake.reload.eip_two).to eq 100
        expect(response).to redirect_to questions_placeholder_question_path
      end
    end
  end
end
