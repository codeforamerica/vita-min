require "rails_helper"

describe Ctc::Questions::MainHomeController, requires_default_vita_partners: true do
  let(:intake) { create :ctc_intake }
  before do
    allow(MixpanelService).to receive(:send_event)
  end

  describe "first page of ctc intake update behavior" do
    include_context :first_page_of_ctc_intake_update_context, form_name: :ctc_main_home_form, additional_params: { home_location: "fifty_states" }
    it_behaves_like :first_page_of_ctc_intake_update
  end

  describe "#edit" do
    it "renders edit template and initializes form" do
      get :edit, params: {}
      expect(response).to render_template :edit
      expect(assigns(:form)).to be_an_instance_of Ctc::MainHomeForm
    end
  end

  describe "#update" do
    include_context :first_page_of_ctc_intake_update_context, form_name: :ctc_main_home_form, additional_params: { home_location: "fifty_states" }
    it "redirects to next path" do
      get :update, params: params

      expect(response).to redirect_to questions_filing_status_path
    end

    it "sends an event to mixpanel with the home data" do
      post :update, params: params

      expect(MixpanelService).to have_received(:send_event).with(
        hash_including(
          event_name: "question_answered",
          data: {
            home_location: "fifty_states",
          }
        )
      )
    end

    context "when client lived in territory or foreign address" do
      include_context :first_page_of_ctc_intake_update_context, form_name: :ctc_main_home_form, additional_params: { home_location: "us_territory" }

      it "redirects to use gyr" do
        get :update, params: params

        expect(response).to redirect_to questions_use_gyr_path
      end
    end
  end
end
