require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::PdfsController, type: :controller do
  let(:email_address) { "test@example.com" }
  let!(:intake) { create(:state_file_archived_intake, state_code: "NY", mailing_state: "NY", email_address: email_address) }
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
        expect(assigns(:state_code)).to eq(intake.state_code)
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
      allow_any_instance_of(described_class).to receive(:redirect_to)
      post :log_and_redirect

      expect(controller).to have_received(:create_state_file_access_log).with("client_pdf_download_click")
      expect(controller).to have_received(:redirect_to)
    end
  end
end
