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

    context "when it is after closing" do
      around do |example|
        Timecop.freeze(Rails.configuration.state_file_end_of_in_progress_intakes + 1.day) do
          example.run
        end
      end
      it "does not redirect them to the about page" do
        get :edit, params: { us_state: :ny }
        expect(response).not_to have_http_status(:redirect)
      end
    end

  end
end