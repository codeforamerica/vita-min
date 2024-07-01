require 'rails_helper'

RSpec.describe StateFile::Questions::AzEligibilityResidenceController do
  describe "#update" do
    # use the eligibility_offboarding_concern shared example if the page
    # should redirect to the state file eligibility offboarding page
    # when it receives a disqualifying answer.
    # requires one example each of eligible_params & ineligible_params
    it_behaves_like :eligibility_offboarding_concern, intake_factory: :state_file_ny_intake do
      let(:eligible_params) do
        {
          us_state: "az",
          state_file_ny_eligibility_residence_form: {
            eligibility_lived_in_state: "yes",
            eligibility_yonkers: "no",
          }
        }
      end

      let(:ineligible_params) do
        {
          us_state: "az",
          state_file_ny_eligibility_residence_form: {
            eligibility_lived_in_state: "yes",
            eligibility_yonkers: "yes",
          }
        }
      end
    end
  end
end