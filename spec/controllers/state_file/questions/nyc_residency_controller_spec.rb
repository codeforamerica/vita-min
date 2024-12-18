require "rails_helper"

RSpec.describe StateFile::Questions::NycResidencyController do
  let(:intake) { create :state_file_ny_intake }
  before do
    sign_in intake
  end

  describe "#update" do
    let!(:efile_device_info) { create :state_file_efile_device_info, :initial_creation, intake: intake, device_id: nil }
    let(:device_id) { "ABC123" }
    let(:params) do
      { state_file_nyc_residency_form: {
          nyc_residency: "none",
          nyc_maintained_home: "yes",
          device_id: device_id
        } }
    end

    context "without device id information due to JS being disabled" do
      let(:device_id) { nil }

      it "flashes an alert and does re-renders edit" do
        post :update, params: params
        expect(flash[:alert]).to eq(I18n.t("general.enable_javascript"))
      end
    end

    context "with device id" do
      it "updates device id" do
        post :update, params: params
        expect(efile_device_info.reload.device_id).to eq "ABC123"
      end
    end

    describe "#next_path" do
      context "with a disqualifying answer" do
        it "redirects to the offboarding page with offboarded_from" do
          post :update, params: {
            state_file_nyc_residency_form: {
              nyc_residency: "none",
              nyc_maintained_home: "yes",
              device_id: "ABC123"
            }
          }

          expected_path = StateFile::Questions::EligibilityOffboardingController.to_path_helper
          expect(response).to redirect_to expected_path
          expect(session[:offboarded_from]).to eq described_class.to_path_helper
        end
      end

      context "when accessed from the review page" do
        it "redirects to the review page" do
          post :update, params: {
            return_to_review: "y",
            state_file_nyc_residency_form: {
              nyc_residency: "full_year",
              device_id: "ABC123"
            }
          }

          expect(response).to redirect_to(controller: "ny_review", action: :edit)
        end
      end

      context "with both a disqualifying answer and a return to review param" do
        it "redirects to offboarding but retains the return to review param in the path to return to" do
          post :update, params: {
            return_to_review: "y",
            state_file_nyc_residency_form: {
              nyc_residency: "part_year",
              device_id: "ABC123"
            }
          }

          expected_path = StateFile::Questions::EligibilityOffboardingController.to_path_helper
          expect(response).to redirect_to expected_path
          expect(session[:offboarded_from]).to eq described_class.to_path_helper(return_to_review: "y")
        end
      end
    end
  end
end