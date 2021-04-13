require "rails_helper"

RSpec.describe Questions::EligibilityController do
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
    let(:params) { { eligibility_form: { had_farm_income: had_farm_income, had_rental_income: had_rental_income, income_over_limit: income_over_limit } } }
    let(:intake_from_session) { create :intake }

    before do
      session[:intake_id] = intake_from_session.id
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
      end
    end
  end
end

