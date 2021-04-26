require "rails_helper"

RSpec.describe Questions::TriageBacktaxesController do
  it_behaves_like :a_controller_which_is_skipped_when_vita_partner_source_param_is_present

  describe "#edit" do
    it "renders the corresponding template" do
      get :edit

      expect(response).to render_template :edit
    end
  end

  describe "#update" do
    let(:filed_previous_years) { "no" }
    let(:params) { { triage_backtaxes_form: { filed_previous_years: filed_previous_years } } }
    before do
      allow(MixpanelService).to receive(:send_event)
    end

    context "when they have not filed previous years" do
      it "redirects to the ARP page" do
        put :update, params: params
        expect(response).to redirect_to triage_arp_questions_path
        expect(MixpanelService).to have_received(:send_event).with(
          hash_including({
                             data:
                                 {
                                     filed_previous_years: "no",
                                 },
                             subject: "triage",
                             event_name: "answered_question"
                         })
        )
      end
    end

    context "when they have filed for previous years" do
      let(:filed_previous_years) { "yes" }
      it "redirects to the next triage question" do
        put :update, params: params
        expect(response).to redirect_to triage_lookback_questions_path
        expect(MixpanelService).to have_received(:send_event).with(
          hash_including({
                             data:
                                 {
                                     filed_previous_years: "yes",
                                 },
                             subject: "triage",
                             event_name: "answered_question"
                         })
        )
      end
    end
  end
end

