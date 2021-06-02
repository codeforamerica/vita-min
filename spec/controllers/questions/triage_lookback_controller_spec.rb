require "rails_helper"

RSpec.describe Questions::TriageLookbackController do
  it_behaves_like :a_controller_which_is_skipped_when_vita_partner_source_param_is_present

  describe "#edit" do
    it "renders the corresponding template" do
      get :edit

      expect(response).to render_template :edit
    end
  end

  describe "#update" do
    let(:had_income_decrease) { "no" }
    let(:had_unemployment) { "no" }
    let(:had_marketplace_insurance) { "no" }
    let(:none) { "no" }
    let(:params) { { triage_lookback_form: { had_income_decrease: had_income_decrease, had_unemployment: had_unemployment, had_marketplace_insurance: had_marketplace_insurance, none: none } } }
    before do
      allow(MixpanelService).to receive(:send_event)
    end

    context "when no options are selected" do
      it "renders the page with errors" do
        put :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).valid?).to eq false
      end
    end

    context "when an option is selected" do
      let(:had_income_decrease) { "yes" }
      it "redirects to the next question" do
        put :update, params: params
        expect(response).to redirect_to triage_simple_tax_questions_path
        expect(MixpanelService).to have_received(:send_event).with(
          hash_including({
                             data:
                                 {
                                     had_income_decrease: "yes",
                                     had_unemployment: "no",
                                     had_marketplace_insurance: "no",
                                     none: "no"
                                 },
                             subject: "triage",
                             event_name: "answered_question"
                         })
        )
      end
    end
  end
end

