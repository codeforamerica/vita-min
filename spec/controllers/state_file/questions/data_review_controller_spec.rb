require "rails_helper"

RSpec.describe StateFile::Questions::DataReviewController do
  let(:intake) { create :state_file_az_intake }
  before do
    session[:state_file_intake] = intake.to_global_id
    sign_in intake
  end

  describe "#edit" do
    it "renders edit template and creates an initial StateFileEfileDeviceInfo" do
      expect do
        get :edit, params: { us_state: "az", state_file_data_review_form: { device_id: "ABC123" } }
      end.to change(StateFileEfileDeviceInfo, :count).by(1)

      expect(response).to render_template :edit
      efile_info = StateFileEfileDeviceInfo.last
      expect(efile_info.event_type).to eq "initial_creation"
      expect(efile_info.ip_address.to_s).to eq "72.34.67.178"
      expect(efile_info.device_id).to eq nil
      expect(efile_info.intake).to eq intake
    end
  end

  describe "#update" do
    let!(:efile_device_info) { create :state_file_efile_device_info, :initial_creation, intake: intake, device_id: nil }

    context "without device id information due to JS being disabled" do
      it "flashes an alert and does re-renders edit" do
        post :update, params: { us_state: "az", device_id: "" }
        expect(flash[:alert]).to eq(I18n.t("general.enable_javascript"))
      end
    end

    context "with device id" do
      it "updates device id" do
        post :update, params: { us_state: "az", state_file_data_review_form: { device_id: "ABC123" } }
        expect(efile_device_info.reload.device_id).to eq "ABC123"
      end
    end
  end
end