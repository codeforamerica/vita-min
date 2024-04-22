require 'rails_helper'

RSpec.describe StateFile::Questions::PhoneNumberSignUpController do
  describe ".show?" do
    context "when contact preference is text message" do
      it "returns true" do
        intake = create(:state_file_az_intake, contact_preference: "text")
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when contact preference is not text message" do
      it "returns false" do
        intake = create(:state_file_az_intake)
        expect(described_class.show?(intake)).to eq false
      end
    end

    describe "#update" do
      let(:intake) { create(:state_file_az_intake, contact_preference: "text", visitor_id: "v1s1t1n9") }
      before do
        sign_in intake
      end
      let(:token) { TextMessageAccessToken.generate!(sms_phone_number: "+14155551212") }
      let(:request_params) do
        {
          us_state: "az",
          state_file_phone_number_sign_up_form: {
            phone_number: "+14155551212",
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
    end
  end
end