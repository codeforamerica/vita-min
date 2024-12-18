require 'rails_helper'

RSpec.describe StateFile::Questions::NcEligibilityController do
  describe "#update" do
    # use the eligibility_offboarding_concern shared example if the page
    # should redirect to the state file eligibility offboarding page
    # when it receives a disqualifying answer.
    # requires one example each of eligible_params & ineligible_params
    it_behaves_like :eligibility_offboarding_concern, intake_factory: :state_file_nc_intake do
      let(:eligible_params) do
        {
          state_file_nc_eligibility_form: {
            eligibility_ed_loan_cancelled: "no",
            eligibility_ed_loan_emp_payment: "no",
          }
        }
      end

      let(:ineligible_params) do
        {
          state_file_nc_eligibility_form: {
            eligibility_ed_loan_cancelled: "yes",
            eligibility_ed_loan_emp_payment: "yes",
          }
        }
      end
    end
  end
end
