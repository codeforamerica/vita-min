require 'rails_helper'

RSpec.describe StateFile::Questions::NjEligibilityHealthInsuranceController do
  describe "#update" do
    it_behaves_like :eligibility_offboarding_concern, intake_factory: :state_file_nj_intake do
      let(:eligible_params) do
        {
          state_file_nj_eligibility_health_insurance_form: {
            eligibility_all_members_health_insurance: "yes",
          }
        }
      end

      let(:ineligible_params) do
        {
          state_file_nj_eligibility_health_insurance_form: {
            eligibility_all_members_health_insurance: "no",
          }
        }
      end
    end

    context "when taxpayer checks no, but is eligible" do
      let(:intake) { create :state_file_nj_intake, :df_data_mfj_both_claimed_dep }
      let(:form_params) do
        {
          state_file_nj_eligibility_health_insurance_form: {
            eligibility_all_members_health_insurance: "no",
          }
        }
      end

      it "saves the checkbox selections" do
        post :update, params: form_params
        intake.reload
        expect(response).not_to redirect_to(controller: "state_file/questions/eligibility_offboarding", action: :edit)
      end
    end
  end
end