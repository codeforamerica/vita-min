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
#  client_id     :bigint
#
# Indexes
#
#  index_email_access_tokens_on_client_id  (client_id)
#  index_email_access_tokens_on_token      (token)
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

  describe "before_create" do
    let(:email_address) { "tom@thumb.com" }
    before do
      5.times do
        create :email_access_token, email_address: email_address
      end
    end

    it "ensures there are no more than 5 active tokens" do
      last = create :email_access_token, email_address: email_address
      expect(described_class.where(email_address: email_address).count).to eq(5)
      expect(described_class.where(email_address: email_address)).to include last
    end
  end

  describe "generate!" do
    let(:email_address) { "marla@mango.com" }
    let(:verification_code) { "123456" }
    let(:hashed_verification_code) { "a_hashed_verification_code"}
    before do
      allow(VerificationCodeService).to receive(:generate).and_return [verification_code, hashed_verification_code]
    end

    it "creates an instance of the class, persisting the hashed code and returns the hashed and raw token" do
      response = described_class.generate!(email_address: email_address)
      expect(VerificationCodeService).to have_received(:generate).with(email_address)
      expect(response[0]).to eq "123456"
      object = described_class.last
      expect(response[1]).to eq object
      expect(object.token).to eq Devise.token_generator.digest(described_class, :token, hashed_verification_code)
      expect(object.email_address).to eq email_address
      expect(object.token_type).to eq "verification_code"
    end
  end
end
