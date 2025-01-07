require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::EmailAddressController, type: :controller do
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

      it "creates an access log and redirects to the verification code page" do
        post :update, params: {
          state_file_archived_intakes_email_address_form: { email_address: valid_email_address }
        }
        expect(assigns(:form)).to be_valid

        access_log = StateFileArchivedIntakeAccessLog.last
        expect(access_log.ip_address).to eq(ip_address)
        expect(access_log.details["email_address"]).to eq(valid_email_address)
        expect(access_log.event_type).to eq("issued_email_challenge")

        expect(response).to redirect_to(
                              state_file_archived_intakes_edit_verification_code_path(email_address: valid_email_address)
                            )
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
