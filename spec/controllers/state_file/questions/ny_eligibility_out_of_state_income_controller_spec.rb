require 'rails_helper'

RSpec.describe StateFile::Questions::NyEligibilityOutOfStateIncomeController do
  describe "#update" do
    # use the eligibility_offboarding_concern shared example if the page
    # should redirect to the state file eligibility offboarding page
    # when it receives a disqualifying answer.
    # requires one example each of eligible_params & ineligible_params
    it_behaves_like :eligibility_offboarding_concern, intake_factory: :state_file_ny_intake do
      let(:eligible_params) do
        {
          state_file_ny_eligibility_out_of_state_income_form: {
            eligibility_out_of_state_income: "no",
            eligibility_part_year_nyc_resident: "no",
          }
        }
      end

      let(:ineligible_params) do
        {
          state_file_ny_eligibility_out_of_state_income_form: {
            eligibility_out_of_state_income: "yes",
            eligibility_part_year_nyc_resident: "yes",
          }
        }
      end
    end
  end
end