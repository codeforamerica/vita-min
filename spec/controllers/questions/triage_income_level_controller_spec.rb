require 'rails_helper'

RSpec.describe Questions::TriageIncomeLevelController do
  describe "#update" do
    before do
      session[:source] = "source_from_session"
      session[:referrer] = "referrer_from_session"
      cookies[:visitor_id] = "some_visitor_id"
    end

    context "with valid params" do
      let(:income_level) { "zero" }
      let(:params) do
        {
          triage_income_level_form: {
            income_level: income_level
          }
        }
      end

      it "persists their answer on a triage model" do
        expect {
          post :update, params: params
        }.to change(Triage, :count).by(1)

        triage = Triage.last
        expect(triage.income_level).to eq('zero')
      end

      it "saves the source param, referrer, & visitor_id and puts the triage in the session" do
        expect {
          post :update, params: params
        }.to change(Triage, :count).by(1)

        triage = Triage.last
        expect(triage.source).to eq("source_from_session")
        expect(triage.referrer).to eq("referrer_from_session")
        expect(triage.visitor_id).to eq("some_visitor_id")
        expect(triage.locale).to eq("en")
        expect(session[:triage_id]).to eq(triage.id)
      end

      context "when the TriageResultService has an opinion on where to go" do
        before do
          allow(TriageResultService).to receive(:new).and_return(double(TriageResultService, after_income_levels: '/a/cool/url'))
        end

        it "goes whenever the TriageResultService says" do
          post :update, params: params

          expect(response).to redirect_to('/a/cool/url')
        end
      end
    end
  end
end
