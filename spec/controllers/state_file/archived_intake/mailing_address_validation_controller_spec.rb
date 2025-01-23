require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::MailingAddressValidationController, type: :controller do
  let(:intake) { create(:state_file_archived_intake, mailing_state: "NY") }
  let(:current_request) { create(:state_file_archived_intake_request, email_address:email_address, failed_attempts: 0, state_file_archived_intake: intake) }
  let(:controller_instance) { described_class.new }
  let(:email_address) { "test@example.com" }
  let(:valid_verification_code) { "123456" }
  let(:invalid_verification_code) { "654321" }

  before do
    Flipper.enable(:get_your_pdf)
    allow(controller).to receive(:current_request).and_return(current_request)
    allow(I18n).to receive(:locale).and_return(:en)
    session[:code_verified] = true
    session[:ssn_verified] = true
  end

  describe "GET #edit" do
    context "when the request is locked" do
      before do
        allow(current_request).to receive(:access_locked?).and_return(true)
      end

      it "redirects to error page" do
        get :edit

        expect(response).to redirect_to(state_file_archived_intakes_verification_error_path)
      end
    end

    context "when the request is not locked" do
      before do
        allow(current_request).to receive(:access_locked?).and_return(false)
      end

      it "renders the edit template with a new MailingAddressValidationForm" do
        get :edit

        expect(assigns(:form)).to be_a(StateFile::ArchivedIntakes::MailingAddressValidationForm)
        expect(response).to render_template(:edit)
      end
    end

    it "redirects to the lockout path when the request is locked" do
      current_request.lock_access!
      get :edit

      expect(response).to redirect_to(state_file_archived_intakes_verification_error_path)
    end

    it "redirect to root if code verification was not completed" do
      session[:code_verified] = nil
      session[:ssn_verified] = true
      get :edit

      expect(response).to redirect_to(root_path)
      expect(StateFileArchivedIntakeAccessLog.last.event_type).to eq("unauthorized_mailing_attempt")
    end

    it "redirect to root if ssn verification was not completed" do
      session[:code_verified] = true
      session[:ssn_verified] = nil
      get :edit

      expect(response).to redirect_to(root_path)
      expect(StateFileArchivedIntakeAccessLog.last.event_type).to eq("unauthorized_mailing_attempt")
    end
  end

  describe "PATCH #update" do
    context "with a valid chosen address" do
      it "creates an access log and redirects to the root path" do
        post :update, params: {
          state_file_archived_intakes_mailing_address_validation_form: { selected_address: intake.full_address, addresses: controller.address_challenge_set}
        }
        expect(assigns(:form)).to be_valid

        access_log = StateFileArchivedIntakeAccessLog.last
        expect(access_log.state_file_archived_intake_request).to eq(current_request)
        expect(access_log.event_type).to eq("correct_mailing_address")

        # expect(response).to redirect_to(state_file_archived_intakes_edit_mailing_address_validation_path)
      end
    end

    context "with an invalid chosen address" do
      it "creates an access log and redirects to the root path and locks the request" do
        post :update, params: {
          state_file_archived_intakes_mailing_address_validation_form: { selected_address: current_request.fake_address_1, addresses: controller.address_challenge_set}
        }
        expect(assigns(:form)).not_to be_valid

        access_log = StateFileArchivedIntakeAccessLog.last
        expect(access_log.state_file_archived_intake_request).to eq(current_request)
        expect(access_log.event_type).to eq("incorrect_mailing_address")
        expect(current_request.access_locked?).to eq(true)
        expect(response).to redirect_to(state_file_archived_intakes_verification_error_path)
      end
    end

    context "without a chosen address" do
      it "creates an access log and redirects to the root path" do
        post :update, params: {
        }
        expect(assigns(:form)).not_to be_valid

        expect(response).to render_template(:edit)
      end
    end
  end
end
