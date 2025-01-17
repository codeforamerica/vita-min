require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::IdentificationNumberController, type: :controller do
  before do
    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:get_your_pdf).and_return(true)
    session[:code_verified] = true
  end

  describe "GET #edit" do
    it "renders the edit template with a new IdentificationNumberForm" do
      get :edit

      expect(assigns(:form)).to be_a(StateFile::ArchivedIntakes::IdentificationNumberForm)
      expect(response).to render_template(:edit)
    end
  end

  describe "PATCH #update" do
    let(:intake_ssn) { "123456789" }
    let(:intake_request_email) { "ohhithere@gmail.com" }
    let!(:archived_intake) { build(:state_file_archived_intake, hashed_ssn: hashed_ssn ) }
    let!(:intake_request) do
      create(:state_file_archived_intake_request,
             state_file_archived_intake: archived_intake,
             ip_address: ip_address,
             email_address: intake_request_email
      )
    end
    let(:hashed_ssn) { SsnHashingService.hash(intake_ssn) }
    let(:ip_address) { "127.0.0.1" }

    before do
      allow(controller).to receive(:ip_for_irs).and_return(ip_address)
      session[:email_address] = "ohhithere@gmail.com"
    end

    # form is valid -> we create the new access log with correct ssn
    context "with a valid ssn" do
      it "creates an access log and redirects to the root path" do
        post :update, params: {
          state_file_archived_intakes_identification_number_form: { ssn: intake_ssn}
        }
        expect(assigns(:form)).to be_valid

        access_log = StateFileArchivedIntakeAccessLog.last
        expect(access_log.state_file_archived_intake_request).to eq(intake_request)
        expect(access_log.event_type).to eq("correct_ssn_challenge")
        expect(session[:ssn_verified]).to eq(true)

        expect(response).to redirect_to(root_path)
      end
    end

    context "with an invalid ssn" do
    end
  end
end
