require 'rails_helper'

RSpec.describe Questions::TriageBacktaxesYearsController do
  describe "#update" do
    let(:triage) { create(:triage) }

    before do
      session[:triage_id] = triage.id
    end

    context "with valid params" do
      context "when the TriageResultService has an opinion on where to go" do
        before do
          allow(TriageResultService).to receive(:new).and_return(double(TriageResultService, after_backtaxes_years: '/a/cool/url'))
        end

        let(:params) do
          {
            triage_backtaxes_years_form: {
              filed_2018: "yes",
              filed_2019: "no",
              filed_2020: "no",
              filed_2021: "no",
            }
          }
        end

        it "goes whenever the TriageResultService says" do
          post :update, params: params

          expect(response).to redirect_to('/a/cool/url')
        end
      end
    end
  end
end
