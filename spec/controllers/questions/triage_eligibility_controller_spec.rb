require "rails_helper"

RSpec.describe Questions::TriageEligibilityController do
  describe "#edit" do
    it "renders the corresponding template" do
      get :edit

      expect(response).to render_template :edit
    end
  end

  describe "#update" do
    let(:had_farm_income) { "no" }
    let(:had_rental_income) { "no" }
    let(:income_over_limit) { "no" }
    let(:params) { { triage_eligibility_form: { had_farm_income: had_farm_income, had_rental_income: had_rental_income, income_over_limit: income_over_limit } } }
    before do
      allow(MixpanelService).to receive(:send_event)
    end

    RSpec.shared_examples "an offboarding flow" do
      describe "triage_eligibility checks" do
        it "offboards them to ineligible path" do
          post :update, params: params

          expect(response).to redirect_to(maybe_ineligible_path)
        end
      end
    end

    context "when they check had farm income" do
      it_behaves_like "an offboarding flow" do
        let(:had_farm_income) { "yes" }
      end
    end

    context "when they check had rental income" do
      it_behaves_like "an offboarding flow" do
        let(:had_rental_income) { "yes" }
      end
    end

    context "when they check had income over limit" do
      it_behaves_like "an offboarding flow" do
        let(:income_over_limit) { "yes" }
      end
    end

    context "when they do not check any of the boxes" do
      it "redirects to the next path" do
        post :update, params: params

        expect(response).to redirect_to(triage_backtaxes_questions_path)
        expect(MixpanelService).to have_received(:send_event).with(
          hash_including({
             data:
             {
              had_farm_income: "no",
              had_rental_income: "no",
              income_over_limit: "no"
             },
             subject: "triage",
             event_name: "answered_question"
             }
          )
        )
      end
    end
  end
end

