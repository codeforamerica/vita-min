require "rails_helper"

RSpec.describe StateFile::Questions::AzPriorLastNamesController do
  let(:intake) { create :state_file_az_intake }
  before do
    sign_in intake
  end

  describe "#update" do
    let!(:efile_device_info) { create :state_file_efile_device_info, :initial_creation, intake: intake, device_id: nil }
    let(:device_id) { "ABC123" }
    let(:params) do
      { us_state: "az",
        state_file_az_prior_last_names_form: {
          has_prior_last_names: "yes",
          prior_last_names: "McTestface",
          device_id: device_id
        } }
    end

    # use the return_to_review_concern shared example if the page
    # should skip to the review page when the return_to_review param is present
    # requires form_params to be set with any other required params
    it_behaves_like :return_to_review_concern do
      let(:form_params) do
        {
          us_state: "az",
          state_file_az_prior_last_names_form: {
            has_prior_last_names: "yes",
            prior_last_names: "McTestface",
            device_id: "ABC123"
          }
        }
      end
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
  end
end