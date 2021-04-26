require "rails_helper"

RSpec.describe Questions::TriageSimpleTaxController do
  it_behaves_like :a_controller_which_is_skipped_when_vita_partner_source_param_is_present

  describe "#edit" do
    it "renders the corresponding template" do
      get :edit

      expect(response).to render_template :edit
    end
  end

  describe "#update" do
    let(:has_simple_taxes) { "yes" }
    let(:params) { { triage_simple_tax_form: { has_simple_taxes: has_simple_taxes } } }
    before do
      allow(MixpanelService).to receive(:send_event)
    end

    context "when yes" do
      it "redirects to the prepare yourself path" do
        put :update, params: params
        expect(response).to redirect_to diy_file_yourself_path
        expect(MixpanelService).to have_received(:send_event).with(
          hash_including({
                             data:
                                 {
                                     has_simple_taxes: "yes",
                                 },
                             subject: "triage",
                             event_name: "answered_question"
                         })
        )
      end
    end

    context "when no" do
      let(:has_simple_taxes) { "no" }
      it "redirects to the next triage question" do
        put :update, params: params
        expect(response).to redirect_to triage_prepare_solo_questions_path
        expect(MixpanelService).to have_received(:send_event).with(
          hash_including({
                             data:
                                 {
                                     has_simple_taxes: "no",
                                 },
                             subject: "triage",
                             event_name: "answered_question"
                         })
        )
      end
    end
  end
end

