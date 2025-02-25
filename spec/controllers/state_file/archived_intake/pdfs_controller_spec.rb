require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::PdfsController, type: :controller do
  let(:email_address) { "test@example.com" }
  let!(:archived_intake) { create(:state_file_archived_intake, state_code: "NY", mailing_state: "NY", email_address: email_address) }
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
    it_behaves_like 'archived intake locked', action: :index, method: :get

    context "by default" do
      it "renders" do
        get :index
        expect(assigns(:state_code)).to eq(archived_intake.state_code)
        expect(response).to render_template(:index)
      end
    end
  end

  describe "POST #log_and_redirect" do
    let(:pdf_url) { "https://example.com/test.pdf" }
    let(:mock_pdf) { spy }

    before do
      allow(controller).to receive(:create_state_file_access_log)
      allow_any_instance_of(StateFileArchivedIntake).to receive(:submission_pdf).and_return(mock_pdf)
      allow(mock_pdf).to receive(:url).and_return(pdf_url)
    end

    it "logs the access event and redirects to the provided pdf_url" do
      post :log_and_redirect

      expect(controller).to have_received(:create_state_file_access_log).with("client_pdf_download_click")
      expect(response).to redirect_to(pdf_url)
    end
  end
end