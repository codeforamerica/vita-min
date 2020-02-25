require "rails_helper"

RSpec.describe Questions::EligibilityController do
  describe "#update" do
    let(:had_farm_income) { "no" }
    let(:had_rental_income) { "no" }
    let(:income_over_limit) { "no" }
    let(:params) { { eligibility_form: { had_farm_income: had_farm_income, had_rental_income: had_rental_income, income_over_limit: income_over_limit } } }

    before do
      session[:source] = "source_from_session"
      session[:referrer] = "referrer_from_session"
    end

    RSpec.shared_examples "an offboarding flow" do
      describe "eligibility checks" do
        it "creates a new intake and offboards them" do
          expect {
            post :update, params: params
          }.to change(Intake, :count).by(1)

          intake = Intake.last
          expect(intake.source).to eq "source_from_session"
          expect(intake.referrer).to eq "referrer_from_session"
          expect(intake.had_farm_income).to eq had_farm_income
          expect(intake.had_rental_income).to eq had_rental_income
          expect(intake.income_over_limit).to eq income_over_limit

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
      it "it creates a new intake and allows them to continue to sign in " do
        expect {
          post :update, params: params
        }.to change(Intake, :count).by(1)

        intake = Intake.last
        expect(intake.source).to eq "source_from_session"
        expect(intake.referrer).to eq "referrer_from_session"
        expect(response).to redirect_to(identity_questions_path)
      end
    end
  end
end

