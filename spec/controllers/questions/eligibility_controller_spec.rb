require "rails_helper"

RSpec.describe Questions::EligibilityController do
  describe "#update" do
    context "when they check one of the boxes" do
      let(:params) { { eligibility_form: { had_farm_income: "yes", had_rental_income: "no", income_over_limit: "no" } } }

      it "creates a new intake and offboards them" do
        expect {
          post :update, params: params
        }.to change(Intake, :count).by(1)

        expect(Intake.last.had_farm_income_yes?).to eq true
        expect(response).to redirect_to(maybe_ineligible_path)
      end
    end

    context "when they do not check any of the boxes" do
      let(:params) { { eligibility_form: { had_farm_income: "no", had_rental_income: "no", income_over_limit: "no" } } }

      it "it creates a new intake and allows them to continue to sign in " do
        expect {
          post :update, params: params
        }.to change(Intake, :count).by(1)

        expect(response).to redirect_to(identity_questions_path)
      end
    end
  end
end

