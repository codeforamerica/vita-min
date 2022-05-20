require "rails_helper"

describe Ctc::Questions::HomeController do
  let(:intake) { create :ctc_intake }

  before do
    session[:intake_id] = intake.id
    allow(MixpanelService).to receive(:send_event)
  end

  describe "#edit" do
    it "renders edit template and initializes form" do
      get :edit, params: {}
      expect(response).to render_template :edit
      expect(assigns(:form)).to be_an_instance_of Ctc::HomeForm
    end
  end

  describe "#update" do
    let(:home_location) { "fifty_states" }
    let(:params) do
      {
        ctc_home_form: {
          home_location: home_location,
        }
      }
    end

    it "redirects to next path" do
      get :update, params: params

      expect(response).to redirect_to questions_life_situations_path
    end

    it "sends an event to mixpanel with the home data" do
      post :update, params: params

      expect(MixpanelService).to have_received(:send_event).with(
        hash_including(
          event_name: "question_answered",
          data: {
            home_location: home_location,
          }
        )
      )
    end

    context "when client lived in territory or foreign address" do
      let(:home_location) { "us_territory" }

      it "redirects to use gyr" do
        get :update, params: params

        expect(response).to redirect_to questions_use_gyr_path
      end
    end

    context "when client lived in Puerto Rico" do
      let(:home_location) { "puerto_rico" }

      it "redirects to use gyr" do
        get :update, params: params

        expect(response).to redirect_to offboarding_cant_use_getctc_pr_path
      end
    end
  end
end
