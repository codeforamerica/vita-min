require "rails_helper"

describe Ctc::Questions::IncomeController do
  context '#update' do
    let(:had_reportable_income) { "no" }
    let(:params) do
      {
        ctc_income_form: {
          timezone: "America/Chicago",
          had_reportable_income: had_reportable_income
        }
      }
    end

    before do
      cookies[:visitor_id] = "visitor-id"
      session[:source] = "some-source"

      allow(MixpanelService).to receive(:send_event)
    end

    it "sends an event to mixpanel" do
      post :update, params: params

      expect(MixpanelService).to have_received(:send_event).with(hash_including(
        event_name: "question_answered",
        data: { had_reportable_income: "no" }
      ))
    end

    context "when answer is yes" do
      let(:had_reportable_income) { "yes" }
      it "redirects out of the flow" do
        post :update, params: params
        expect(response).to redirect_to questions_use_gyr_path
      end
    end

    context "when the answer is no" do
      let(:had_reportable_income) { "no" }

      it "redirects to the next page in the flow" do
        post :update, params: params
        expect(response).to redirect_to questions_file_full_return_path
      end
    end
  end
end
