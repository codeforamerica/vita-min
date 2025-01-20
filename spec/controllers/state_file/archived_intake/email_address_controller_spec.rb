require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::EmailAddressController, type: :controller do
  before do
    Flipper.enable(:get_your_pdf)
  end
  describe "GET #edit" do
    it "renders the edit template with a new EmailAddressForm" do
      get :edit

      expect(assigns(:form)).to be_a(StateFile::ArchivedIntakes::EmailAddressForm)
      expect(response).to render_template(:edit)
    end
  end

  describe "POST #update" do
    let(:valid_email_address) { "test@example.com" }
    let(:invalid_email_address) { "" }
    let(:ip_address) { "127.0.0.1" }

    before do
      allow(controller).to receive(:ip_for_irs).and_return(ip_address)
    end

    context "when the form is valid" do
      context "and a archived intake exists with the email address" do
        let!(:archived_intake) { create :state_file_archived_intake, email_address: valid_email_address }
        it "creates an access log create a request and redirects to the verification code page" do
          post :update, params: {
            state_file_archived_intakes_email_address_form: { email_address: valid_email_address }
          }
          expect(assigns(:form)).to be_valid

          request = StateFileArchivedIntakeRequest.last
          expect(request.ip_address).to eq(ip_address)
          expect(request.email_address).to eq(valid_email_address)
          expect(request.state_file_archived_intake_id).to eq(archived_intake.id)

          log = StateFileArchivedIntakeAccessLog.last
          expect(log.state_file_archived_intake_request_id).to eq(request.id)
          expect(log.event_type).to eq("issued_email_challenge")

          expect(response).to redirect_to(
                                state_file_archived_intakes_edit_verification_code_path
                              )
        end
      end

      context "and a archived does not exist with the email address" do
        it "creates an access log create a request and redirects to the verification code page" do
          post :update, params: {
            state_file_archived_intakes_email_address_form: { email_address: valid_email_address }
          }
          expect(assigns(:form)).to be_valid

          request = StateFileArchivedIntakeRequest.last
          expect(request.ip_address).to eq(ip_address)
          expect(request.email_address).to eq(valid_email_address)
          expect(request.state_file_archived_intake_id).to eq(nil)

          log = StateFileArchivedIntakeAccessLog.last
          expect(log.state_file_archived_intake_request_id).to eq(request.id)
          expect(log.event_type).to eq("issued_email_challenge")

          expect(response).to redirect_to(
                                state_file_archived_intakes_edit_verification_code_path
                              )
        end
      end
    end
    context "when the form is invalid" do
      it "renders the edit template" do
        post :update, params: {
          state_file_archived_intakes_email_address_form: { email_address: invalid_email_address }
        }

        expect(assigns(:form)).not_to be_valid

        expect(StateFileArchivedIntakeAccessLog.count).to eq(0)

        expect(response).to render_template(:edit)
      end
    end
  end
end
