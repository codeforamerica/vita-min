require 'rails_helper'

RSpec.describe Questions::TriageIncomeLevelController do
  describe "#update" do
    before do
      session[:source] = "source_from_session"
      session[:referrer] = "referrer_from_session"
      cookies[:visitor_id] = "some_visitor_id"
    end

    context "with valid params" do
      let(:intake) { create :intake, need_itin_help: "no" }
      let(:params) do
        {
          triage_income_level_form: {
            triage_filing_status: "single",
            triage_income_level: "zero",
            triage_filing_frequency: "some_years",
            triage_vita_income_ineligible: "yes",
          }
        }
      end

      before do
        session[:intake_id] = intake.id
      end

      it "persists their answer on a intake model" do
        post :update, params: params

        intake.reload
        expect(intake.triage_filing_status).to eq("single")
        expect(intake.triage_income_level).to eq("zero")
        expect(intake.triage_filing_frequency).to eq("some_years")
        expect(intake.triage_vita_income_ineligible).to eq("yes")
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
