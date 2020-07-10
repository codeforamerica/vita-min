require 'rails_helper'

RSpec.describe Questions::FeedbackController, type: :controller do
  let(:intake) { create :intake, intake_ticket_id: 1234 }

  describe "#edit" do
    context "with a completed intake in the session" do
      before do
        session[:completed_intake_id] = intake.id
      end

      it "returns success" do
        get :edit

        expect(response).to be_ok
      end
    end

    context "without a completed intake in the session" do
      it "redirect to the beginning of intake" do
        get :edit

        expect(response.status).to eq 302
      end
    end
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          feedback_form: {
            feedback: "This whole website seems like a simulation. Is it real?"
          }
        }
      end

      context "with a completed intake id in the session" do
        before { session[:completed_intake_id] = intake.id }

        it "saves the answer to the corresponding intake" do
          post :update, params: params

          expect(intake.reload.feedback).to eq "This whole website seems like a simulation. Is it real?"
        end
      end

      context "without a completed intake in the session" do
        it "redirects elsewhere without updating the intake" do
          post :update, params: params

          expect(response.status).to eq 302
        end
      end
    end
  end
end
