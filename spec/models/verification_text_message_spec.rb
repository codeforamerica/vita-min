# == Schema Information
#
# Table name: text_message_login_requests
#
#  id                           :bigint           not null, primary key
#  twilio_sid                   :string
#  twilio_status                :string
#  text_message_access_token_id :bigint           not null
#  visitor_id                   :string           not null
#
# Indexes
#
#  index_text_message_login_requests_on_twilio_sid  (twilio_sid)
#  index_text_message_login_requests_on_visitor_id  (visitor_id)
#  text_message_login_request_access_token_id       (text_message_access_token_id)
#
require "rails_helper"

describe VerificationTextMessage do
  describe "#valid?" do
    describe "required fields" do
      it "adds an error for any missing required fields" do
        login_request = described_class.new

        expect(login_request).not_to be_valid
        expect(login_request.errors).to include(:text_message_access_token)
        expect(login_request.errors).to include(:visitor_id)
      end

      it "is valid with all required fields" do
        login_request = described_class.new(
          text_message_access_token: create(:text_message_access_token),
          visitor_id: "some random visitor id",
        )
        expect(login_request).to be_valid
      end
    end
  end
end
