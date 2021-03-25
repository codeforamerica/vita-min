require 'rails_helper'

RSpec.describe Questions::SuccessfullySubmittedController, type: :controller do
  render_views

  let(:intake) { create :intake }
  let(:client) { intake.client }

  before do
    allow(MixpanelService).to receive(:send_event)
  end

  describe "#include_analytics?" do
    it "returns true" do
      expect(subject.include_analytics?).to eq true
    end
  end

  describe "#edit" do
    context "with an authenticated client " do
      before { sign_in client }

      it "signs out the client and sets a completed_intake_id in the session" do
        expect do
          get :edit
        end.to change{ subject.current_client }.from(client).to(nil)

        expect(session[:completed_intake_id]).to eq intake.id
      end

      it "displays a confirmation number" do
        get :edit

        expect(response.body).to include "Your confirmation number is: #{intake.client_id}"
      end

      it "sends a mixpanel event with the intake in the session" do
        get :edit

        expect(MixpanelService).to have_received(:send_event).with(hash_including(subject: intake))
      end
    end

    context "without an authenticated client or intake in the session" do
      it "Still renders the page with a success message" do
        get :edit

        expect(response.body).to include "Success! Your tax information has been submitted."
      end
    end
  end

  describe "#update" do
    context "with a completed intake id in the session" do
      before { session[:completed_intake_id] = intake.id }

      context "with valid params" do
        let(:params) do
          {
            satisfaction_face_form: {
              satisfaction_face: "negative"
            }
          }
        end

        it "saves the answer to the corresponding intake" do
          post :update, params: params

          expect(intake.reload.satisfaction_face).to eq "negative"
        end

        it "sends a mixpanel event with the completed intake in the session" do
          post :update, params: params

          expect(MixpanelService).to have_received(:send_event).with(hash_including(subject: intake))
        end
      end
    end
  end

  describe "#prev_path" do
    it "returns nil" do
      expect(subject.prev_path).to be_nil
    end
  end
end
