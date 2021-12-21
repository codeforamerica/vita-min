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
#  client_id        :bigint
#
# Indexes
#
#  index_text_message_access_tokens_on_client_id         (client_id)
#  index_text_message_access_tokens_on_sms_phone_number  (sms_phone_number)
#  index_text_message_access_tokens_on_token             (token)
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

  describe "after_create" do
    before do
      allow(DatadogApi).to receive(:increment)
    end

    it "should increment datadog metric" do
      create :text_message_access_token
      expect(DatadogApi).to have_received(:increment).with("client_logins.verification_codes.text_message.created")
    end
  end

  describe "before_create" do
    let(:phone_number) { "+18324658840" }
    before do
      5.times do
        create :text_message_access_token, sms_phone_number: phone_number
      end
    end

    it "ensures there are no more than 5 active tokens" do
      last = create :text_message_access_token, sms_phone_number: phone_number
      expect(described_class.where(sms_phone_number: phone_number).count).to eq(5)
      expect(described_class.where(sms_phone_number: phone_number)).to include last
    end
  end

  describe "generate!" do
    let(:phone_number) { "+15125551234" }
    let(:verification_code) { "123456" }
    let(:hashed_verification_code) { "a_hashed_verification_code"}
    before do
      allow(VerificationCodeService).to receive(:generate).and_return [verification_code, hashed_verification_code]
    end

    it "creates an instance of the class, persisting the hashed code and returns the hashed and raw token" do
      response = described_class.generate!(sms_phone_number: phone_number)
      expect(response[0]).to eq "123456"
      object = TextMessageAccessToken.last
      expect(response[1]).to eq object
      expect(object.token).to eq Devise.token_generator.digest(described_class, :token, hashed_verification_code)
      expect(object.sms_phone_number).to eq phone_number
      expect(object.token_type).to eq "verification_code"
    end
  end
end
