require "rails_helper"

RSpec.describe StateFile::Questions::EsignDeclarationController do
  let(:intake) { create :state_file_az_intake }
  let(:device_id) { "ABC123" }
  let(:params) do
    {
      primary_esigned: "yes",
      spouse_esigned: "yes",
      state_file_esign_declaration_form: {
        device_id: device_id,
      }
    }
  end
  before do
    sign_in intake
  end

  describe "#edit" do
    it "renders edit template and creates an initial StateFileEfileDeviceInfo" do
      expect do
        get :edit, params: params
      end.to change(StateFileEfileDeviceInfo, :count).by(1)

      expect(response).to render_template :edit
      efile_info = StateFileEfileDeviceInfo.last
      expect(efile_info.event_type).to eq "submission"
      expect(efile_info.ip_address.to_s).to eq "72.34.67.178"
      expect(efile_info.device_id).to eq nil
      expect(efile_info.intake).to eq intake
    end

    context "when it is after closing" do
      around do |example|
        Timecop.freeze(Rails.configuration.state_file_end_of_in_progress_intakes + 1.day) do
          example.run
        end
      end

      context "when there is a submission" do
        before do
          create :efile_submission, data_source: intake
        end
        it "redirects them to the return status page" do
          get :edit
          expect(response).to redirect_to(questions_return_status_path)
        end
      end

      context "when there no submission" do
        it "redirects them to the return about page" do
          get :edit
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

  describe "#update" do
    let!(:efile_device_info) { create :state_file_efile_device_info, :submission, intake: intake, device_id: nil }

    context "without device id information due to JS being disabled" do
      let(:device_id) { "" }
      it "flashes an alert and does re-renders edit" do
        post :update, params: params
        expect(flash[:alert]).to eq(I18n.t("general.enable_javascript"))
      end
    end

    context "with device id and signatures" do
      it "updates device id and signatures" do
        post :update, params: params
        expect(efile_device_info.reload.device_id).to eq "ABC123"
      end
    end
  end
end