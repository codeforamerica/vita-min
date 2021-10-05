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

      it "displays a confirmation number" do
        get :edit

        expect(response.body).to include "Your confirmation number is: #{intake.client_id}"
      end

      it "sends a mixpanel event with the intake in the session" do
        get :edit

        expect(MixpanelService).to have_received(:send_event).with(hash_including(subject: intake))
      end
    end
  end

  describe "#update" do
    context "with a completed intake id in the session" do
      before { sign_in client }

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
end
