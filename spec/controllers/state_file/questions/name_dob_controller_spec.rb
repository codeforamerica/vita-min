require "rails_helper"

RSpec.describe StateFile::Questions::NameDobController do
  let(:intake) { create :state_file_az_intake }
  let(:device_id) { "ABC123" }
  let(:params) do
    {
      us_state: "az",
      state_file_name_dob_form: {
        device_id: device_id,
        primary_first_name: "Jo",
        primary_last_name: "Parker",
      },
    }
  end
  let!(:efile_device_info) { create :state_file_efile_device_info, :initial_creation, intake: intake, device_id: nil }

  before do
    session[:state_file_intake] = intake.to_global_id
    sign_in intake
  end

  describe "#update" do
    context "with device id" do
      it "updates device id" do
        post :update, params: params
        expect(efile_device_info.reload.device_id).to eq "ABC123"
      end
    end
  end
end