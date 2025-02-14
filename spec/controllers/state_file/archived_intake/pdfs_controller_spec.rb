require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::PdfsController, type: :controller do
  let(:email_address) { "test@example.com" }
  let!(:intake) { create(:state_file_archived_intake, mailing_state: "NY", email_address: email_address) }
  let(:current_request) { create(:state_file_archived_intake_request, email_address: email_address, failed_attempts: 0, state_file_archived_intake: intake) }
  let(:controller_instance) { described_class.new }
  let(:valid_verification_code) { "123456" }
  let(:invalid_verification_code) { "654321" }

  before do
    Flipper.enable(:get_your_pdf)
    allow(controller).to receive(:current_request).and_return(current_request)
    allow(I18n).to receive(:locale).and_return(:en)
    session[:email_address] = true
    session[:code_verified] = true
    session[:ssn_verified] = true
    session[:mailing_verified] = true
  end

  describe "GET #index" do
    context "request is locked" do
      before do
        allow(current_request).to receive(:access_locked?).and_return(true)
      end

      it "redirects to error page" do
        get :index

        expect(response).to redirect_to(state_file_archived_intakes_verification_error_path)
      end
    end

    context "email address is not verified" do
      before do
        session[:code_verified] = nil
      end

      it "redirects to the email verification page" do
        get :index

        expect(response).to redirect_to(state_file_archived_intakes_verification_error_path)
      end
    end

    context "ssn is not verified" do
      before do
        session[:ssn_verified] = nil
      end

      it "redirects to the ssn verification page" do
        get :index

        expect(response).to redirect_to(state_file_archived_intakes_verification_error_path)
      end
    end

    context "mailing address is not verified" do
      before do
        session[:mailing_verified] = nil
      end

      it "redirects to the ssn verification page" do
        get :index

        expect(response).to redirect_to(state_file_archived_intakes_verification_error_path)
      end
    end

    context "by default" do
      it "renders" do
        get :index

        expect(assigns(:prior_year_intake)).to eq(intake)
        expect(response).to render_template(:index)
      end
    end
  end

  describe "POST #log_and_redirect" do
    let(:pdf_url) { "https://example.com/test.pdf" }

    before do
      allow(controller).to receive(:create_state_file_access_log)
    end

    it "logs the access event and redirects to the provided pdf_url" do
      allow_any_instance_of(described_class).to receive(:redirect_to).and_call_original

      post :log_and_redirect, params: { pdf_url: pdf_url }

      expect(controller).to have_received(:create_state_file_access_log).with("client_pdf_download_click")
      expect(controller).to have_received(:redirect_to).with(pdf_url)
    end
  end
end

=begin

RSpec.describe StateFile::ArchivedIntakes::MailingAddressValidationController, type: :controller do
  describe "GET #edit" do
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
      it "creates an access log and redirects to the download page" do
        post :update, params: {
          state_file_archived_intakes_mailing_address_validation_form: { selected_address: intake.full_address, addresses: current_request.address_challenge_set}
        }
        expect(assigns(:form)).to be_valid

        access_log = StateFileArchivedIntakeAccessLog.last
        expect(access_log.state_file_archived_intake_request).to eq(current_request)
        expect(access_log.event_type).to eq("correct_mailing_address")
        expect(session[:mailing_verified]).to eq(true)

        expect(response).to redirect_to(state_file_archived_intakes_pdfs_path)
      end
    end

    context "with an invalid chosen address" do
      it "creates an access log and redirects to the root path and locks the request" do
        post :update, params: {
          state_file_archived_intakes_mailing_address_validation_form: { selected_address: current_request.fake_address_1, addresses: current_request.address_challenge_set}
        }
        expect(assigns(:form)).not_to be_valid

        access_log = StateFileArchivedIntakeAccessLog.last
        expect(access_log.state_file_archived_intake_request).to eq(current_request)
        expect(access_log.event_type).to eq("incorrect_mailing_address")
        expect(session[:mailing_verified]).to eq(nil)
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
=end
