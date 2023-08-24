require "rails_helper"

describe VerificationCodeService do
  describe ".generate" do
    before do
      allow(SecureRandom).to receive(:rand).with(1000000).and_return(4)
      allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with("example@example.com", "000004").and_return("hashed_verification_code")
    end

    it "generates a 6-digit random code and its digest" do
      expect(described_class.generate("example@example.com")).to eq(["000004", "hashed_verification_code"])
    end
  end

  describe ".hash_verification_code_with_contact_info" do
    before do
      allow(Devise.token_generator).to receive(:digest).with(VerificationCodeService, :verification_code, "example@example.com,000004").and_return("hashed_verification_code")
    end

    it "hashes tokens with Devise.token_generator" do
      expect(described_class.hash_verification_code_with_contact_info("example@example.com", "000004")).to eq("hashed_verification_code")
    end
  end
end
