require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::VerificationCodeController, type: :controller do
  let(:email_address) { "test@example.com" }
  let!(:archived_intake) { build(:state_file_archived_intake, email_address: email_address) }
  let(:valid_verification_code) { "123456" }
  let(:invalid_verification_code) { "654321" }

  before do
    Flipper.enable(:get_your_pdf)
    allow(controller).to receive(:current_archived_intake).and_return(archived_intake)
    allow(I18n).to receive(:locale).and_return(:en)
  end

  describe "GET #edit" do
    it_behaves_like 'archived intake locked', action: :edit, method: :get


    context "when the request is not locked" do
      before do
        allow(archived_intake).to receive(:access_locked?).and_return(false)
      end

      it "renders the edit template with a new VerificationCodeForm and queues a job" do
        expect{
          get :edit
        }.to have_enqueued_job(ArchivedIntakeEmailVerificationCodeJob).with(
          email_address: email_address,
          locale: :en
        )

        expect(assigns(:form)).to be_a(StateFile::ArchivedIntakes::VerificationCodeForm)
        expect(assigns(:email_address)).to eq(email_address)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "POST #update" do
    context "with a valid verification code" do
      before do
        allow_any_instance_of(StateFile::ArchivedIntakes::VerificationCodeForm).to receive(:valid?).and_return(true)
      end

      it "creates a success access log for correct email code, creates a access log for issued ssn challenge, and does not increment failed_attempts" do
        expect {
          post :update, params: { state_file_archived_intakes_verification_code_form: { verification_code: valid_verification_code } }
        }.to change(StateFileArchivedIntakeAccessLog, :count).by(2)

        last_two_logs = StateFileArchivedIntakeAccessLog.last(2).pluck(:event_type)
        expect(last_two_logs).to include("issued_ssn_challenge", "correct_email_code")
        expect(session[:code_verified]).to eq(true)
        expect(archived_intake.failed_attempts).to eq(0)
        expect(response).to redirect_to(state_file_archived_intakes_edit_identification_number_path)
      end
    end

    context "with an invalid verification code" do
      before do
        allow_any_instance_of(StateFile::ArchivedIntakes::VerificationCodeForm).to receive(:valid?).and_return(false)
      end

      it "creates a failure access log, increments failed_attempts, and re-renders edit on first failed attempt" do
        expect {
          post :update, params: { state_file_archived_intakes_verification_code_form: { verification_code: invalid_verification_code } }
        }.to change(StateFileArchivedIntakeAccessLog, :count).by(1)

        log = StateFileArchivedIntakeAccessLog.last
        expect(log.event_type).to eq("incorrect_email_code")
        expect(session[:code_verified]).to eq(nil)

        expect(archived_intake.reload.failed_attempts).to eq(1)
        expect(assigns(:form)).to be_a(StateFile::ArchivedIntakes::VerificationCodeForm)
        expect(response).to render_template(:edit)
      end

      it "locks the account and redirects to root path after multiple failed attempts" do
        archived_intake.update!(failed_attempts: 1)

        expect {
          post :update, params: { state_file_archived_intakes_verification_code_form: { verification_code: invalid_verification_code } }
        }.to change(StateFileArchivedIntakeAccessLog, :count).by(2)

        log = StateFileArchivedIntakeAccessLog.last
        expect(log.event_type).to eq("client_lockout_begin")
        expect(session[:code_verified]).to eq(nil)

        expect(archived_intake.reload.failed_attempts).to eq(2)
        expect(archived_intake.reload.access_locked?).to be_truthy
        expect(response).to redirect_to(state_file_archived_intakes_verification_error_path)
      end
    end
  end
end
