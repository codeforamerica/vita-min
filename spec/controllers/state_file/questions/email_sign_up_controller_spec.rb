require 'rails_helper'

RSpec.describe StateFile::Questions::EmailSignUpController do
  render_views
  let(:intake) { create(:state_file_az_intake, contact_preference: "email", visitor_id: "v1s1t1n9") }
  before do
    sign_in intake
  end

  describe ".show?" do
    context "when contact preference is email" do
      it "returns true" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when contact preference is not email" do
      let(:intake) { create(:state_file_az_intake) }

      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end
  end

  describe "#edit" do

    it "displays a form for entering an email address" do
      get :edit, params: { us_state: "az" }
      expect(response).to be_ok
      expect(response.body).to have_text("Enter your email address")
    end
  end

  describe "#create" do

    it "enqueues a job to send verification code text message" do
      expect {
        post :create, params: {
          us_state: "az",
          state_file_email_sign_up_form: {
            email_address: "admin@fileyourstatetaxes.org"
          }
        }
      }.to have_enqueued_job(RequestVerificationCodeEmailJob).with(
        email_address: "admin@fileyourstatetaxes.org",
        locale: I18n.locale,
        visitor_id: intake.visitor_id,
        client_id: nil,
        service_type: :statefile
      )
      expect(response.body).to have_text("Enter the 6-digit code")
    end
  end

  describe "#update" do
    let(:token) { EmailAccessToken.generate!(email_address: "admin@fileyourstatetaxes.org") }
    let(:request_params) do
      {
        us_state: "az",
        state_file_email_sign_up_form: {
          email_address: "admin@fileyourstatetaxes.org",
          verification_code: token[0]
        }
      }
    end

    it "validates the access token" do
      put :update, params: request_params
      expect(response).to redirect_to(
        StateFile::Questions::CodeVerifiedController.to_path_helper(
          action: :edit,
          us_state: "az"
        )
      )
    end

    context "with an intake matching an existing intake" do
      before do
        create(:state_file_az_intake,
           contact_preference: "email",
           email_address: "admin@fileyourstatetaxes.org",
           visitor_id: "v1s1t1n9"
        )
      end

      it "redirects to login" do
        post :update, params: request_params
        login_location = StateFile::IntakeLoginsController.to_path_helper(
          action: :edit,
          id: VerificationCodeService.hash_verification_code_with_contact_info(
            "admin@fileyourstatetaxes.org", token[0]
          ),
          us_state: "az"
        )
        expect(response).to redirect_to(login_location)
      end
    end
  end
end