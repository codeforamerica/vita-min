require 'rails_helper'

RSpec.describe StateFile::Questions::LandingPageController do
  describe "#update" do
    # use the shared example to test functionality for creating the intake
    # This can be moved to a different controller spec but the valid params
    # will need to be defined for the new controller

    it_behaves_like :start_intake_concern, intake_class: StateFileAzIntake, intake_factory: :state_file_az_intake do
      let(:valid_params) do
        {
          us_state: "az"
        }
      end
    end

    it_behaves_like :start_intake_concern, intake_class: StateFileNyIntake, intake_factory: :state_file_ny_intake do
      let(:valid_params) do
        {
          us_state: "ny"
        }
      end
    end
  end

  describe "#edit" do
    let(:intake) { create :state_file_ny_intake }
    before do
      sign_in intake
    end

    it "does not set the current_step" do
      get :edit, params: { us_state: :ny }
      expect(response).to be_ok
      expect(StateFileNyIntake.last.current_step).to be_nil
    end


  end
end