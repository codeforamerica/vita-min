require "rails_helper"

RSpec.describe Questions::TriagePrepareSoloController do
  it_behaves_like :a_controller_which_is_skipped_when_vita_partner_source_param_is_present

  describe "#edit" do
    it "renders the corresponding template" do
      get :edit

      expect(response).to render_template :edit
    end
  end

  describe "#update" do
    let(:will_prepare) { "yes" }
    let(:params) { { triage_prepare_solo_form: { will_prepare: will_prepare } } }
    before do
      allow(MixpanelService).to receive(:send_event)
    end

    context "when yes" do
      it "redirects to the diy path" do
        put :update, params: params
        expect(response).to redirect_to diy_file_yourself_path
        expect(MixpanelService).to have_received(:send_event).with(
          hash_including({
                             data:
                                 {
                                     will_prepare: "yes",
                                 },
                             subject: "triage",
                             event_name: "answered_question"
                         })
        )
      end
    end

    context "when no" do
      let(:will_prepare) { "no" }
      it "redirects to the file with help page" do
        put :update, params: params
        expect(response).to redirect_to file_with_help_questions_path
        expect(MixpanelService).to have_received(:send_event).with(
          hash_including({
                             data:
                                 {
                                     will_prepare: "no",
                                 },
                             subject: "triage",
                             event_name: "answered_question"
                         })
        )
      end
    end
  end
end

