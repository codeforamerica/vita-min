require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::MailingAddressValidationController, type: :controller do
  let(:archived_intake) { create(:state_file_archived_intake, mailing_state: "NY") }
  let(:email_address) { "test@example.com" }
  let(:valid_verification_code) { "123456" }
  let(:invalid_verification_code) { "654321" }

  before do
    Flipper.enable(:get_your_pdf)
    allow(controller).to receive(:current_archived_intake).and_return(archived_intake)
    allow(I18n).to receive(:locale).and_return(:en)
    session[:code_verified] = true
    session[:ssn_verified] = true
  end

  describe "GET #edit" do
    it_behaves_like 'archived intake locked', action: :edit, method: :get

    context "when the request is locked" do
      before do
        allow(archived_intake).to receive(:access_locked?).and_return(true)
      end
    end

    context "when the request is not locked" do
      before do
        allow(archived_intake).to receive(:access_locked?).and_return(false)
      end

      it "renders the edit template with a new MailingAddressValidationForm" do
        get :edit

        expect(assigns(:form)).to be_a(StateFile::ArchivedIntakes::MailingAddressValidationForm)
        expect(response).to render_template(:edit)
      end
    end

    it "redirects to root if code verification was not completed" do
      session[:code_verified] = nil
      session[:ssn_verified] = true
      get :edit

      expect(response).to redirect_to(root_path)
      expect(StateFileArchivedIntakeAccessLog.last.event_type).to eq("unauthorized_mailing_attempt")
    end

    it "redirects to root if ssn verification was not completed" do
      session[:code_verified] = true
      session[:ssn_verified] = nil
      get :edit

      expect(response).to redirect_to(root_path)
      expect(StateFileArchivedIntakeAccessLog.last.event_type).to eq("unauthorized_mailing_attempt")
    end
  end

  describe "PATCH #update" do
    context "with a valid chosen address" do
      it "creates an access log and redirects to the download page" do
        post :update, params: {
          state_file_archived_intakes_mailing_address_validation_form: { selected_address: archived_intake.full_address, addresses: archived_intake.address_challenge_set}
        }
        expect(assigns(:form)).to be_valid

        access_log = StateFileArchivedIntakeAccessLog.last
        expect(access_log.state_file_archived_intake).to eq(archived_intake)
        expect(access_log.event_type).to eq("correct_mailing_address")
        expect(session[:mailing_verified]).to eq(true)

        expect(response).to redirect_to(state_file_archived_intakes_pdfs_path)
      end
    end

    context "with an invalid chosen address" do
      it "creates an access log, locks the request, and redirects to the verification error path" do
        post :update, params: {
          state_file_archived_intakes_mailing_address_validation_form: { selected_address: archived_intake.fake_address_1, addresses: archived_intake.address_challenge_set}
        }
        expect(assigns(:form)).not_to be_valid

        access_log = StateFileArchivedIntakeAccessLog.last
        expect(access_log.state_file_archived_intake).to eq(archived_intake)
        expect(access_log.event_type).to eq("incorrect_mailing_address")
        expect(session[:mailing_verified]).to eq(nil)
        expect(archived_intake.permanently_locked_at).to be_present
        expect(response).to redirect_to(state_file_archived_intakes_verification_error_path)
      end
    end

    context "without a chosen address" do
      it "creates an access log and re-renders the edit template" do
        post :update, params: {}
        expect(assigns(:form)).not_to be_valid

        expect(response).to render_template(:edit)
      end
    end
  end
end
