require 'rails_helper'

RSpec.describe StateFile::Questions::VerificationCodeController do
  describe "#edit" do
    before do
      session[:state_file_intake] = intake.to_global_id
    end

    context "with an intake that prefers text message" do
      let(:intake) { create(:state_file_az_intake, contact_preference: "text", phone_number: "+14153334444") }

      it "sets @contact_method to a pretty phone number" do
        get :edit, params: { us_state: "az" }

        expect(assigns(:contact_info)).to eq "(415) 333-4444"
      end
    end

    context "with an intake that prefers email" do
      let(:intake) { create(:state_file_az_intake, contact_preference: "email", email_address: "someone@example.com") }

      it "sets @contact_method to an email address" do
        get :edit, params: { us_state: "az" }

        expect(assigns(:contact_info)).to eq "someone@example.com"
      end
    end
  end

  describe "#update" do
    xit "validates the verification code" do
    end

    xit "authenticates the user" do
    end
  end
end