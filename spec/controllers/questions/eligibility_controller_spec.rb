require "rails_helper"

RSpec.describe Questions::EligibilityController do
  describe "#edit" do
    context "without an intake" do
      it "redirects to the beginning of the intake flow" do
        get :edit

        expect(response).to redirect_to(question_path(:id => QuestionNavigation.first))
      end
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

    context "without an intake" do
      before do
        session[:intake_id] = nil
      end

      it "redirects to the beginning of the intake flow" do
        post :update, params: params

        expect(response).to redirect_to(question_path(:id => QuestionNavigation.first))
      end
    end

    context "with an authenticated user" do
      let(:intake) { create :intake }
      let(:user) { create :user, intake: intake }

      before do
        sign_in user
      end

      it "updates the intake associated with the user" do
        post :update, params: params

        intake.reload
        expect(intake.had_farm_income).to eq had_farm_income
        expect(intake.had_rental_income).to eq had_rental_income
        expect(intake.income_over_limit).to eq income_over_limit
      end
    end

    RSpec.shared_examples "an offboarding flow" do
      describe "eligibility checks" do
        it "updates the intake from the session and offboards them" do
          post :update, params: params

          intake_from_session.reload
          expect(intake_from_session.had_farm_income).to eq had_farm_income
          expect(intake_from_session.had_rental_income).to eq had_rental_income
          expect(intake_from_session.income_over_limit).to eq income_over_limit

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
      it "updates the intake from the session and allows them to continue to sign in " do
        post :update, params: params

        intake_from_session.reload
        expect(intake_from_session.had_farm_income).to eq had_farm_income
        expect(intake_from_session.had_rental_income).to eq had_rental_income
        expect(intake_from_session.income_over_limit).to eq income_over_limit
        expect(response).to redirect_to(overview_questions_path)
      end
    end
  end
end

