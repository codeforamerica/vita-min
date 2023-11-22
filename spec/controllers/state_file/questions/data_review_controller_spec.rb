require "rails_helper"

RSpec.describe StateFile::Questions::DataReviewController do
  let(:intake) { create :state_file_az_intake }
  before do
    session[:state_file_intake] = intake.to_global_id
  end

  describe "#edit" do
    it "renders edit template" do
      expect do
        get :edit, params: { us_state: "az", device_id: "ABC123" }
      end.to change(StateFileEfileDeviceInfo, :count).by(1)

      expect(response).to render_template :edit
      efile_info = StateFileEfileDeviceInfo.last
      expect(efile_info.event_type).to eq "initial_creation"
      expect(efile_info.ip_address.to_s).to eq "0.0.0.0"
      expect(efile_info.device_id).to eq nil
      expect(efile_info.intake).to eq intake
    end
  end

  # describe "#update" do
  #   # use the return_to_review_concern shared example if the page
  #   # should skip to the review page when the return_to_review param is present
  #   # requires form_params to be set with any other required params
  #   it_behaves_like :return_to_review_concern do
  #     let(:form_params) do
  #       {
  #         us_state: "az",
  #         state_file_az_prior_last_names_form: {
  #           has_prior_last_names: "yes",
  #           prior_last_names: "McTestface"
  #         }
  #       }
  #     end
  #   end
  # end


end