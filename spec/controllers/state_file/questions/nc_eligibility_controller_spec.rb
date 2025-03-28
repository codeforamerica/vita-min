require 'rails_helper'

RSpec.describe StateFile::Questions::NcEligibilityController do
  describe "eligibility_offboarding concern" do
    it_behaves_like :eligibility_offboarding_concern, intake_factory: :state_file_nc_intake do
      let(:eligible_params) do
        {
          state_file_nc_eligibility_form: {
            nc_eligiblity_none: "yes",
            eligibility_ed_loan_cancelled: "unfilled",
            eligibility_ed_loan_emp_payment: "no",
          }
        }
      end

      let(:ineligible_params) do
        {
          state_file_nc_eligibility_form: {
            nc_eligiblity_none: "unfilled",
            eligibility_ed_loan_cancelled: "yes",
            eligibility_ed_loan_emp_payment: "no",
          }
        }
      end
    end
  end
end
