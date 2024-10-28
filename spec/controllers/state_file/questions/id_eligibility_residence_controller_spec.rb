require 'rails_helper'

RSpec.describe StateFile::Questions::IdEligibilityResidenceController do
  describe "#update" do
    # use the eligibility_offboarding_concern shared example if the page
    # should redirect to the state file eligibility offboarding page
    # when it receives a disqualifying answer.
    # requires one example each of eligible_params & ineligible_params
    it_behaves_like :eligibility_offboarding_concern, intake_factory: :state_file_id_intake do
      let(:eligible_params) do
        {
          state_file_id_eligibility_residence_form: {
            eligibility_withdrew_msa_fthb: "no",
            eligibility_emergency_rental_assistance: "no",
          }
        }
      end

      let(:ineligible_params) do
        {
          state_file_id_eligibility_residence_form: {
            eligibility_withdrew_msa_fthb: "yes",
            eligibility_emergency_rental_assistance: "yes",
          }
        }
      end
    end
  end
end