require "rails_helper"

RSpec.describe Questions::TriageTaxNeedsController do
  describe "#edit" do
    it "renders the corresponding template" do
      get :edit

      expect(response).to render_template :edit
    end
  end

  describe "#update" do
    let(:file_this_year) { "no" }
    let(:file_previous_years) { "no" }
    let(:collect_stimulus) { "no" }
    let(:params) { { triage_tax_needs_form: { file_this_year: file_this_year, file_previous_years: file_previous_years, collect_stimulus: collect_stimulus } } }
    before do
      allow(MixpanelService).to receive(:send_event)
    end

    context "without at least one selection" do
      it "renders edit" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).valid?).to eq false
      end
    end

    context "with only collect stimulus selected" do
      let(:collect_stimulus) { "yes" }
      it "redirects to stimulus check path" do
        post :update, params: params
        expect(response).to redirect_to triage_stimulus_check_questions_path
        expect(MixpanelService).to have_received(:send_event).with(
          hash_including({
                             data:
                                 {
                                     collect_stimulus: "yes",
                                     file_previous_years: "no",
                                     file_this_year: "no"
                                 },
                             subject: "triage",
                             event_name: "answered_question"
                         })
        )
      end
    end

    context "with multiple options selected" do
      let(:collect_stimulus) { "yes" }
      let(:file_previous_years) { "yes" }
      it "redirects to next path" do
        post :update, params: params
        expect(response).to redirect_to triage_eligibility_questions_path
        expect(MixpanelService).to have_received(:send_event).with(
          hash_including({
                             data:
                                 {
                                     collect_stimulus: "yes",
                                     file_previous_years: "yes",
                                     file_this_year: "no"
                                 },
                             subject: "triage",
                             event_name: "answered_question"
                         })
        )
      end
    end
  end
end

