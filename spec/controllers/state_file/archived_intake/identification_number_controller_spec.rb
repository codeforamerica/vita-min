require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::IdentificationNumberController, type: :controller do
  let(:intake_ssn) { "123456789" }
  let(:invalid_ssn) { "212345678" }
  let(:intake_request_email) { "ohhithere@gmail.com" }
  let!(:archived_intake) { build(:state_file_archived_intake, hashed_ssn: hashed_ssn ) }
  let!(:intake_request) do
    create(:state_file_archived_intake_request,
           state_file_archived_intake: archived_intake,
           ip_address: ip_address,
           email_address: intake_request_email,
           failed_attempts: 0
    )
  end
  let(:hashed_ssn) { SsnHashingService.hash(intake_ssn) }
  let(:ip_address) { "127.0.0.1" }

  before do
    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:get_your_pdf).and_return(true)
    session[:code_verified] = true
    allow(controller).to receive(:ip_for_irs).and_return(ip_address)
    session[:email_address] = "ohhithere@gmail.com"
  end

  describe "GET #edit" do
    it "renders the edit template with a new IdentificationNumberForm" do
      get :edit

      expect(assigns(:form)).to be_a(StateFile::ArchivedIntakes::IdentificationNumberForm)
      expect(response).to render_template(:edit)
    end

    it "redirects to the root path when the request is locked" do
      intake_request.lock_access!
      get :edit

      expect(response).to redirect_to(root_path)
    end

    it "redirect to root if code verification was not completed" do
      session[:code_verified] = nil
      get :edit

      expect(response).to redirect_to(root_path)
      expect(StateFileArchivedIntakeAccessLog.last.event_type).to eq("unauthorized_ssn_attempt")
    end
  end

  describe "PATCH #update" do
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
        expect(intake_request.reload.failed_attempts).to eq(0)

        expect(response).to redirect_to(root_path)
      end

      it "resets failed attempts to zero even if one failed attempt has already been made" do
        intake_request.update!(failed_attempts: 1)

        post :update, params: {
          state_file_archived_intakes_identification_number_form: { ssn: intake_ssn}
        }

        expect(assigns(:form)).to be_valid
        expect(intake_request.reload.failed_attempts).to eq(0)
      end
    end

    context "with an invalid ssn" do
      before do
        allow_any_instance_of(StateFile::ArchivedIntakes::VerificationCodeForm).to receive(:valid?).and_return(false)
      end

      it "creates a failure access log, increments failed_attempts, and re-renders edit on first failed attempt" do
        expect {
          post :update, params: { state_file_archived_intakes_identification_number_form: { ssn: invalid_ssn } }
        }.to change(StateFileArchivedIntakeAccessLog, :count).by(1)

        log = StateFileArchivedIntakeAccessLog.last
        expect(log.event_type).to eq("incorrect_ssn_challenge")

        expect(intake_request.reload.failed_attempts).to eq(1)
        expect(response).to render_template(:edit)
      end

      it "locks the account and redirects to root path after multiple failed attempts" do
        intake_request.update!(failed_attempts: 1)

        expect {
          post :update, params: { state_file_archived_intakes_identification_number_form: { ssn: invalid_ssn } }
        }.to change(StateFileArchivedIntakeAccessLog, :count).by(2)

        log = StateFileArchivedIntakeAccessLog.last
        expect(log.event_type).to eq("client_lockout_begin")

        expect(intake_request.reload.failed_attempts).to eq(2)
        expect(intake_request.reload.access_locked?).to be_truthy
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
