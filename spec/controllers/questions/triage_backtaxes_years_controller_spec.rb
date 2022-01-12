require 'rails_helper'

RSpec.describe Questions::TriageBacktaxesYearsController do
  describe "#update" do
    context "with valid params" do

      context "with triage answers that are within the filing limit and with at least some documents and with SSN/ITIN paperwork" do
        let(:triage) { create(:triage, id_type: "have_paperwork", income_level: "hh_1_to_25100", doc_type: "some_copies") }

        before do
          session[:triage_id] = triage.id
        end

        context "when they need help with any non-2021 year" do
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

          it "redirects to start of full service" do
            post :update, params: params

            expect(response).to redirect_to(Questions::TriageIncomeTypesController.to_path_helper)
          end
        end
      end

      context "with triage answers that do not have any documents" do
        let(:triage) { create(:triage, income_level: "hh_1_to_25100", doc_type: "need_help") }

        before do
          session[:triage_id] = triage.id
        end

        context "when they need help with any non-2021 year" do
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

          it "redirects to the next page in the flow" do
            post :update, params: params

            expect(response).to redirect_to(Questions::TriageAssistanceController.to_path_helper)
          end
        end
      end

      context "with triage answers that do not have SSN/ITIN paperwork" do
        let(:triage) { create(:triage, id_type: "know_number", income_level: "hh_1_to_25100", doc_type: "some_copies") }

        before do
          session[:triage_id] = triage.id
        end

        context "when they need help with any non-2021 year" do
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

          it "redirects to the next page in the flow" do
            post :update, params: params

            expect(response).to redirect_to(Questions::TriageAssistanceController.to_path_helper)
          end
        end
      end
    end
  end
end
