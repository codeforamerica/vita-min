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
    let(:mixed_case_email_address) { "Test@Example.COM" }
    let(:invalid_email_address) { "" }
    let(:ip_address) { "127.0.0.1" }

    before do
      allow(controller).to receive(:ip_for_irs).and_return(ip_address)
    end

    context "when the form is valid" do
      context "and an archived intake exists with the email address" do
        let!(:archived_intake) { create :state_file_archived_intake, email_address: valid_email_address }
        it "creates an access log, creates a request, and redirects to the verification code page" do
          post :update, params: {
            state_file_archived_intakes_email_address_form: { email_address: valid_email_address }
          }
          expect(assigns(:form)).to be_valid
          active_archived_intake = controller.send(:current_archived_intake)
          expect(active_archived_intake.email_address).to eq(valid_email_address)
          expect(active_archived_intake.hashed_ssn).to eq(archived_intake.hashed_ssn)
          expect(active_archived_intake.id).to eq(archived_intake.id)

          log = StateFileArchivedIntakeAccessLog.last
          expect(log.state_file_archived_intake_id).to eq(archived_intake.id)
          expect(log.event_type).to eq("issued_email_challenge")

          expect(response).to redirect_to(
                                state_file_archived_intakes_edit_verification_code_path
                              )
        end

        it "matches email case insensitively" do
          post :update, params: {
            state_file_archived_intakes_email_address_form: { email_address: mixed_case_email_address }
          }

          expect(assigns(:form)).to be_valid

          active_archived_intake = controller.send(:current_archived_intake)
          expect(active_archived_intake.email_address).to eq(valid_email_address)
          expect(active_archived_intake.hashed_ssn).to eq(archived_intake.hashed_ssn)
          expect(active_archived_intake.id).to eq(archived_intake.id)

          expect(response).to redirect_to(
                                state_file_archived_intakes_edit_verification_code_path
                              )
        end

        it "resets verification session variables sets the email address" do
          post :update, params: {
            state_file_archived_intakes_email_address_form: { email_address: "new@example.com" }
          }

          expect(assigns(:form)).to be_valid

          expect(session[:ssn_verified]).to be(false)
          expect(session[:mailing_verified]).to be(false)
          expect(session[:code_verified]).to be(false)

          expect(session[:email_address]).to eq("new@example.com")
        end
      end

      context "and an archived intake does not exist with the email address" do
        it "creates an access log, creates a new archived intake without a ssn or address, and redirects to the verification code page" do
          post :update, params: {
            state_file_archived_intakes_email_address_form: { email_address: valid_email_address }
          }
          expect(assigns(:form)).to be_valid

          active_archived_intake = controller.send(:current_archived_intake)
          expect(active_archived_intake.email_address).to eq(valid_email_address)
          expect(active_archived_intake.hashed_ssn).to eq(nil)
          expect(active_archived_intake.full_address).to eq("")

          log = StateFileArchivedIntakeAccessLog.last
          expect(log.state_file_archived_intake_id).to eq(active_archived_intake.id)
          expect(log.event_type).to eq("issued_email_challenge")

          expect(response).to redirect_to(
                                state_file_archived_intakes_edit_verification_code_path
                              )
        end

        it "resets verification session variables and sets email" do
          post :update, params: {
            state_file_archived_intakes_email_address_form: { email_address: valid_email_address }
          }

          expect(assigns(:form)).to be_valid

          expect(session[:ssn_verified]).to be(false)
          expect(session[:mailing_verified]).to be(false)
          expect(session[:code_verified]).to be(false)

          expect(session[:email_address]).to eq(valid_email_address)
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
