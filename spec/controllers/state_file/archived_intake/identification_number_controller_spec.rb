require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::IdentificationNumberController, type: :controller do
  describe "GET #edit" do
    it "renders the edit template with a new IdentificationNumberForm" do
      get :edit

      expect(assigns(:form)).to be_a(StateFile::ArchivedIntakes::IdentificationNumberForm)
      expect(response).to render_template(:edit)
    end
  end

  describe "PATCH #update" do
    let(:ssn) { "test@example.com" }
    let(:ip_address) { "127.0.0.1" }

    before do
      allow(controller).to receive(:ip_for_irs).and_return(ip_address)
    end

    context "when the form is valid" do

      # form is valid -> we create the new access log with correct ssn
      # form is invalid -> we create the new access log without the correct ssn & check how many attempts they have left

      it "creates an access log and redirects to the root path" do
        post :update, params: {
          state_file_archived_intakes_number_form: { ssn: valid_email_address }
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
