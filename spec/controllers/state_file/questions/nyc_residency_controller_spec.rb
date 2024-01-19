require "rails_helper"

RSpec.describe StateFile::Questions::NycResidencyController do
  let(:intake) { create :state_file_ny_intake }
  before do
    session[:state_file_intake] = intake.to_global_id
    sign_in intake
  end

  describe "#update" do
    describe "#next_path" do
      context "with a disqualifying answer" do
        it "redirects to the offboarding page with offboarded_from" do
          post :update, params: {
            us_state: "ny",
            state_file_nyc_residency_form: {
              nyc_residency: "none",
              nyc_maintained_home: "yes"
            }
          }

          expected_path = StateFile::Questions::EligibilityOffboardingController.to_path_helper(
            us_state: "ny")
          expect(response).to redirect_to expected_path
          expect(session[:offboarded_from]).to eq described_class.to_path_helper(us_state: "ny")
        end
      end
    end
  end
end