require "rails_helper"

describe Ctc::Portal::PagesController do
  let(:primary_birth_date) { 30.years.ago }
  let(:wages_amount) { 1000 }
  let(:intake) do
    create :ctc_intake,
           primary_birth_date: primary_birth_date,
           current_step: "en/portal/dependents/not-eligible",
           dependents: [],
           claim_eitc: 'yes',
           primary_tin_type: 'ssn',
           exceeded_investment_income_limit: 'no'

  end
  let!(:w2) { create :w2, wages_amount: wages_amount, intake: intake }
  let!(:client) { create :client, intake: intake, tax_returns: [create(:tax_return)] }

  before do
    allow(subject).to receive(:open_for_eitc_intake?).and_return true
    sign_in intake.client
  end

  context "#no_eligible_dependents" do
    it "renders no_eligible_dependents template" do
      get :no_eligible_dependents
      expect(response).to render_template :no_eligible_dependents
    end

    context "client is 30 years old and has no qualifying dependents" do

      context "total income below the income threshold" do
        it "should not return EITC in ineligible credits" do
          get :no_eligible_dependents
          expect(assigns(:ineligible_credits)).not_to include "EITC"
        end
      end

      context "total income above the income threshold" do
        let(:wages_amount) { 12_000 }

        it "should return EITC in ineligible credits" do
          get :no_eligible_dependents
          expect(assigns(:ineligible_credits)).to include "EITC"
        end
      end
    end

    context "when a client 20 years old and has no qualifying dependents" do
      let(:primary_birth_date) { 20.years.ago }
      it "should return EITC in ineligible credits" do
        get :no_eligible_dependents
        expect(assigns(:ineligible_credits)).to include "EITC"
        expect(assigns(:ineligible_credits)).not_to include "CTC"
      end
    end

  end
end