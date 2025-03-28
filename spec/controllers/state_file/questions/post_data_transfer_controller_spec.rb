require "rails_helper"

RSpec.describe StateFile::Questions::PostDataTransferController do
  StateFile::StateInformationService.active_state_codes.excluding("ny").each do |state_code|
    it_behaves_like :df_data_required, false, state_code
  end

  let(:intake) { create :state_file_az_intake }
  before do
    sign_in intake
    intake.update(df_data_import_succeeded_at: DateTime.now - 5.minutes)
  end

  describe "#edit" do
    it "displays the Data Review edit page" do
      get :edit

      expect(response).to render_template :edit
    end

    context "with valid federal data" do
      it "renders edit template and creates an initial StateFileEfileDeviceInfo" do
        expect do
          get :edit
        end.to change(StateFileEfileDeviceInfo, :count).by(1)

        efile_info = StateFileEfileDeviceInfo.last
        expect(efile_info.event_type).to eq "initial_creation"
        expect(efile_info.ip_address.to_s).to eq "72.34.67.178"
        expect(efile_info.device_id).to eq nil
        expect(efile_info.intake).to eq intake
      end
    end

    context "with disqualifying federal data" do
      it "redirects to the offboard screen" do
        allow_any_instance_of(DirectFileData).to receive(:filing_status).and_return(3)
        response = get :edit
        expect(response).to redirect_to(StateFile::Questions::DataTransferOffboardingController.to_path_helper)
      end
    end

    context "with federal data which we could not import successfully" do
      before do
        intake.update(df_data_import_succeeded_at: nil)
      end

      it "redirects to the offboard screen" do
        response = get :edit
        expect(response).to redirect_to(StateFile::StateFilePagesController.to_path_helper(action: "data_import_failed"))
      end

      context "for New Jersey which does calculations with imported direct_file_data" do
        let(:intake) { create :state_file_nj_intake }
        before do
          allow_any_instance_of(DirectFileData).to receive(:filing_status).and_return(nil)
        end

        it "redirects to offboard screen" do
          response = get :edit
          expect(response).to redirect_to(StateFile::StateFilePagesController.to_path_helper(action: "data_import_failed"))
        end
      end
    end

    context 'when the session times out/ is destroyed' do
      it 'redirects to the landing page for the correct state' do
        session.destroy
        response = get :edit
        expect(response).to redirect_to(StateFile::StateFilePagesController.to_path_helper(action: :login_options))
        expect(flash[:notice]).to eq('Your session expired. Please sign in again to continue.')
      end
    end
  end
end