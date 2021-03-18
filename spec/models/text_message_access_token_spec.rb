# == Schema Information
#
# Table name: text_message_access_tokens
#
#  id               :bigint           not null, primary key
#  sms_phone_number :string           not null
#  token            :string           not null
#  token_type       :string           default("link")
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_text_message_access_tokens_on_token  (token)
#
require "rails_helper"

describe TextMessageAccessToken do
  describe "#valid?" do
    describe "required fields" do
      it "adds an error for any missing required fields" do
        access_token = described_class.new

        expect(access_token).not_to be_valid
        expect(access_token.errors).to include(:sms_phone_number)
        expect(access_token.errors).to include(:token)
      end

      it "is valid with all required fields" do
        access_token = described_class.new(
          token: "a8sd7hf98a7sdhf8a",
          sms_phone_number: "+15005550006",
        )
        expect(access_token).to be_valid
      end
    end

    describe "#sms_phone_number" do
      let(:access_token) { build :text_message_access_token, sms_phone_number: sms_phone_number }
      context "with an invalid phone number" do
        let(:sms_phone_number) { "500 5550" }

        it "is not valid" do
          expect(access_token).not_to be_valid
          expect(access_token.errors).to include :sms_phone_number
        end
      end

      context "with a valid phone number" do
        let(:sms_phone_number) { "+15005550006" }

        it "is valid" do
          expect(access_token).to be_valid
        end
      end
    end

    describe "#token_type" do
      let(:access_token) { build :text_message_access_token, token_type: token_type }

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
