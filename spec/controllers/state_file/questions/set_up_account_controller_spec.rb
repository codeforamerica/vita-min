require 'rails_helper'

RSpec.describe StateFile::Questions::SetUpAccountController do
  describe "#update" do
    # use the shared example to test functionality for creating the intake
    # This can be moved to a different controller spec but the valid params
    # will need to be defined for the new controller
    it_behaves_like :start_intake_concern do
      let(:valid_params) do
        {
          us_state: "az",
          state_file_set_up_account_form: {
            contact_preference: "email"
          }
        }
      end
    end
  end
end
