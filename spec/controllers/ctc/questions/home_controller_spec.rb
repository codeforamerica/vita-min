require "rails_helper"

describe Ctc::Questions::HomeController do
  let(:intake) { create :ctc_intake }

  describe "#edit" do
    it_behaves_like :a_get_action_for_authenticated_ctc_clients_only, action: :edit

    context "as an authenticated ctc client" do
      before do
        sign_in intake.client
        allow(MixpanelService).to receive(:send_event)
      end

      it "renders edit template and initializes form" do
        get :edit, params: {}
        expect(response).to render_template :edit
        expect(assigns(:form)).to be_an_instance_of Ctc::HomeForm
        expect(assigns(:form).intake).to be_an_instance_of Intake::CtcIntake
      end
    end
  end

  describe "#update" do
    let(:params) do
      {
        ctc_home_form: {
          lived_in_fifty_states: "yes",
          lived_at_military_facility: "yes",
          lived_in_us_territory: "yes",
          lived_at_foreign_address: "no"
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_ctc_clients_only, action: :update

    context "as an authenticated ctc client" do
      before do
        sign_in intake.client
        allow(MixpanelService).to receive(:send_event)
      end

      it "saves the form and redirects to the next step" do
        get :update, params: params

        expect(response).to redirect_to questions_use_gyr_path
      end

      it "sends an event to mixpanel with the home data" do
        post :update, params: params

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
                                                                     event_name: "question_answered",
                                                                     data: {
                                                                         lived_in_fifty_states: "yes",
                                                                         lived_at_military_facility: "yes",
                                                                         lived_in_us_territory: "yes",
                                                                         lived_at_foreign_address: "no"
                                                                     }
                                                                   ))
      end
    end
  end
end