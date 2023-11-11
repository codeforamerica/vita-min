require 'rails_helper'

RSpec.describe StateFile::Questions::EligibilityResidenceController do
  describe "#update" do
    # use the shared example to test functionality for creating the intake
    # This can be moved to a different controller spec but the valid params
    # will need to be defined for the new controller

    it_behaves_like :start_intake_concern, intake_class: StateFileAzIntake, intake_factory: :state_file_az_intake do
      let(:valid_params) do
        {
          us_state: "az",
          state_file_az_eligibility_residence_form: {
            eligibility_lived_in_state: "yes",
            eligibility_married_filing_separately: "no"
          }
        }
      end
    end

    it_behaves_like :start_intake_concern, intake_class: StateFileNyIntake, intake_factory: :state_file_ny_intake do
      let(:valid_params) do
        {
          us_state: "ny",
          state_file_ny_eligibility_residence_form: {
            eligibility_lived_in_state: "yes",
            eligibility_yonkers: "yes",
          }
        }
      end
    end

    # use the eligibility_offboarding_concern shared example if the page
    # should redirect to the state file eligibility offboarding page
    # when it receives a disqualifying answer.
    # requires one example each of eligible_params & ineligible_params
    it_behaves_like :eligibility_offboarding_concern, intake_factory: :state_file_ny_intake do
      let(:eligible_params) do
        {
          us_state: "ny",
          state_file_ny_eligibility_residence_form: {
            eligibility_lived_in_state: "yes",
            eligibility_yonkers: "no",
          }
        }
      end

      let(:ineligible_params) do
        {
          us_state: "ny",
          state_file_ny_eligibility_residence_form: {
            eligibility_lived_in_state: "yes",
            eligibility_yonkers: "yes",
          }
        }
      end
    end
  end
end