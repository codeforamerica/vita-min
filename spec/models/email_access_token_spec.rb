# == Schema Information
#
# Table name: email_access_tokens
#
#  id            :bigint           not null, primary key
#  email_address :citext           not null
#  token         :string           not null
#  token_type    :string           default("link")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_email_access_tokens_on_token  (token)
#
require "rails_helper"

describe EmailAccessToken do
  describe "#valid?" do
    describe "required fields" do
      it "adds an error for any missing required fields" do
        access_token = described_class.new

        expect(access_token).not_to be_valid
        expect(access_token.errors).to include(:email_address)
        expect(access_token.errors).to include(:token)
      end

      it "is valid with all required fields" do
        access_token = described_class.new(
          token: "a8sd7hf98a7sdhf8a",
          email_address: "someone@example.com",
        )
        expect(access_token).to be_valid
      end
    end

    describe "#email_address" do
      let(:access_token) { build :email_access_token, email_address: email_address }
      context "with an invalid email address" do
        let(:email_address) { "someone@somewhere" }

        it "is not valid" do
          expect(access_token).not_to be_valid
          expect(access_token.errors).to include :email_address
        end
      end

      context "with a valid email address" do
        let(:email_address) { "someone@example.com" }

        it "is valid" do
          expect(access_token).to be_valid
        end
      end

      context "with comma-separated email addresses" do
        let(:email_address) { "someone@example.com,other@example.com" }

        it "is valid" do
          expect(access_token).to be_valid
        end
      end
    end

    describe "#token_type" do
      let(:access_token) { build :email_access_token, token_type: token_type }

      context "with a valid token type" do
        let(:token_type) { "verification_code" }

        it "is valid" do
          expect(access_token).to be_valid
        end
      end

      context "with an invalid token type" do
        let(:token_type) { "not_a_type" }

        it "is not valid" do
          expect(access_token).not_to be_valid
        end
      end
    end
  end
end
