# == Schema Information
#
# Table name: email_login_requests
#
#  id                    :bigint           not null, primary key
#  mailgun_status        :string
#  email_access_token_id :bigint           not null
#  mailgun_id            :string
#  visitor_id            :string           not null
#
# Indexes
#
#  index_email_login_requests_on_email_access_token_id  (email_access_token_id)
#  index_email_login_requests_on_mailgun_id             (mailgun_id)
#  index_email_login_requests_on_visitor_id             (visitor_id)
#
require "rails_helper"

describe VerificationEmail do
  describe "#valid?" do
    describe "required fields" do
      it "adds an error for any missing required fields" do
        login_request = described_class.new

        expect(login_request).not_to be_valid
        expect(login_request.errors).to include(:email_access_token)
        expect(login_request.errors).to include(:visitor_id)
      end

      it "is valid with all required fields" do
        login_request = described_class.new(
          email_access_token: create(:email_access_token),
          visitor_id: "some random visitor id",
        )
        expect(login_request).to be_valid
      end
    end
  end
end
