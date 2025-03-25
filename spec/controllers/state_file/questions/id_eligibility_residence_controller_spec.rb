require 'rails_helper'

RSpec.describe StateFile::Questions::IdEligibilityResidenceController do
  describe "eligibility_offboarding_concern" do
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