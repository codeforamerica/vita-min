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
  end
end