require 'rails_helper'

RSpec.describe StateFile::Questions::ContactPreferenceController do
  describe "#update" do
    # use the shared example to test functionality for creating the intake
    # This can be moved to a different controller spec but the valid params
    # will need to be defined for the new controller
    it_behaves_like :start_intake_concern, intake_class: StateFileAzIntake, intake_factory: :state_file_az_intake do
      let(:valid_params) do
        {
          us_state: "az",
          state_file_contact_preference_form: {
            contact_preference: "email"
          }
        }
      end
    end
  end
end