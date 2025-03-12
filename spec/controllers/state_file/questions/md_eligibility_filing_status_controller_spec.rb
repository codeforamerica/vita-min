require "rails_helper"

describe StateFile::Questions::MdEligibilityFilingStatusController do
  let(:intake) { create :state_file_md_intake }
  before do
    sign_in intake
  end

  describe "#edit" do
    render_views

    it "succeeds" do
      get :edit
      expect(response).to be_successful
      expect(response_html).to have_text I18n.t("state_file.questions.md_eligibility_filing_status.edit.title", year: MultiTenantService.statefile.current_tax_year)
    end
  end

  describe "eligibility_offboarding_concern" do
    it_behaves_like :eligibility_offboarding_concern, intake_factory: :state_file_md_intake do
      let(:eligible_params) do
        {
          state_file_md_eligibility_filing_status_form: {
            eligibility_filing_status_mfj: "yes",
            eligibility_homebuyer_withdrawal: "no",
            eligibility_homebuyer_withdrawal_mfj: "no",
            eligibility_home_different_areas: "no"
          }
        }
      end

      let(:ineligible_params) do
        {
          state_file_md_eligibility_filing_status_form: {
            eligibility_filing_status_mfj: "yes",
            eligibility_homebuyer_withdrawal: "yes",
            eligibility_homebuyer_withdrawal_mfj: "yes",
            eligibility_home_different_areas: "no"
          }
        }
      end
    end
  end
end
