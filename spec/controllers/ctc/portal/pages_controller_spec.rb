require "rails_helper"

describe Ctc::Portal::PagesController do
  let(:primary_birth_date) { 30.years.ago }
  let(:wages_amount) { 1000 }
  let(:claim_eitc) { "yes" }
  let(:intake) do
    create :ctc_intake,
           primary_birth_date: primary_birth_date,
           current_step: "en/portal/dependents/not-eligible",
           dependents: [],
           claim_eitc: claim_eitc,
           primary_tin_type: 'ssn',
           exceeded_investment_income_limit: 'no'

  end
  let!(:w2) { create :w2, wages_amount: wages_amount, intake: intake }
  let!(:client) { create :client, intake: intake, tax_returns: [create(:ctc_tax_return)] }

  before do
    allow(subject).to receive(:open_for_eitc_intake?).and_return true
    sign_in intake.client
  end

  describe "#dependent_removal_summary" do
    context "redirects" do
      context "when client is eligible for CTC and EITC" do
        before do
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:any_eligible_ctc_dependents?).and_return true
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:claiming_and_qualified_for_eitc?).and_return true
        end

        it "redirects to portal edit info" do
          get :dependent_removal_summary
          expect(response).to redirect_to ctc_portal_edit_info_path
        end
      end

      context "when a client is eligible for CTC and ineligible for EITC but is not claiming it" do
        let(:claim_eitc) { "no" }
        before do
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:any_eligible_ctc_dependents?).and_return true
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:claiming_and_qualified_for_eitc?).and_return false
        end

        it "redirects to portal edit info" do
          get :dependent_removal_summary
          expect(response).to redirect_to ctc_portal_edit_info_path
        end
      end
    end

    context "when eligibility may have changed due to dependent removal" do
      context "when client is not eligible for CTC but is eligible for EITC" do
        before do
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:any_eligible_ctc_dependents?).and_return false
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:claiming_and_qualified_for_eitc?).and_return true
        end

        it "does return CTC in ineligible credits" do
          get :dependent_removal_summary
          expect(response).to be_ok
          expect(assigns(:credit_warnings)).to include "CTC"
        end
      end

      context "when client is eligible for CTC and is claiming EITC but is ineligible for it" do
        before do
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:any_eligible_ctc_dependents?).and_return true
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:claiming_and_qualified_for_eitc?).and_return false
        end

        it "shows a page saying the dependent you just deleted makes you ineligible for EITC" do
          get :dependent_removal_summary
          expect(response).to be_ok
          expect(assigns(:credit_warnings)).to include "EITC"
        end
      end

      context "when client is ineligible for CTC and is claiming EITC but is ineligible for it" do
        before do
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:any_eligible_ctc_dependents?).and_return false
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:claiming_and_qualified_for_eitc?).and_return false
        end

        it "shows a page saying the dependent you just deleted makes you ineligible for both" do
          get :dependent_removal_summary
          expect(response).to be_ok
          expect(assigns(:credit_warnings)).to eq I18n.t("views.ctc.portal.dependents.dependent_removal_summary.ctc_and_eitc")
        end
      end
    end
  end
end