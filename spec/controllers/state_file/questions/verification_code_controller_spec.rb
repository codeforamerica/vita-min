require 'rails_helper'

RSpec.describe StateFile::Questions::VerificationCodeController do
  describe "#edit" do
    before do
      sign_in intake
    end

    context "with an intake that prefers text message" do
      let(:intake) { create(:state_file_az_intake, contact_preference: "text", phone_number: "+14153334444", visitor_id: "v1s1t1n9") }

      it "sets @contact_info to a pretty phone number" do
        get :edit, params: { us_state: "az" }

        expect(assigns(:contact_info)).to eq "(415) 333-4444"
      end

      it "enqueues a job to send verification code text message" do
        expect {
          get :edit, params: { us_state: "az" }
        }.to have_enqueued_job(RequestVerificationCodeTextMessageJob).with(
          phone_number: intake.phone_number,
          locale: I18n.locale,
          visitor_id: intake.visitor_id,
          client_id: nil,
          service_type: :statefile
        )
      end
    end

    context "with an intake that prefers email" do
      let(:intake) { create(:state_file_az_intake, contact_preference: "email", email_address: "someone@example.com", visitor_id: "v1s1t1n9") }

      it "sets @contact_info to an email address" do
        get :edit, params: { us_state: "az" }

        expect(assigns(:contact_info)).to eq "someone@example.com"
      end

      it "enqueues a job to send verification code email" do
        expect {
          get :edit, params: { us_state: "az" }
        }.to have_enqueued_job(RequestVerificationCodeEmailJob).with(
          email_address: intake.email_address,
          locale: I18n.locale,
          visitor_id: intake.visitor_id,
          client_id: nil,
          service_type: :statefile
        )
      end
    end

    context "with an intake matching an existing intake" do
      let(:intake) { create(:state_file_az_intake, contact_preference: "email", email_address: "someone@example.com", visitor_id: "v1s1t1n9") }
      let(:token) { EmailAccessToken.generate!(email_address: "someone@example.com") }

      it "redirects to login" do
        post :update, params: { us_state: "az", state_file_verification_code_form: { verification_code: token[0] }}
        login_location = StateFile::IntakeLoginsController.to_path_helper(
          action: :edit,
          id: VerificationCodeService.hash_verification_code_with_contact_info(
            "someone@example.com", token[0]
          ),
          us_state: "az"
        )
        expect(response).to redirect_to(login_location)
      end
    end
  end
end