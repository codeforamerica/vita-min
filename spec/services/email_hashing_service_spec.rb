require 'rails_helper'

describe EmailHashingService do
  describe '.hash' do
    before do
      allow(EnvironmentCredentials).to receive(:[]).with('DUPLICATE_HASHING_KEY').and_return('test-key')
    end

    it "returns an HMAC-SHA256 hex digest" do
      result = described_class.hash("user@example.com")
      expect(result).to eq(OpenSSL::HMAC.hexdigest("SHA256", "test-key", "email|user@example.com"))
    end

    it "normalizes email to lowercase before hashing" do
      expect(described_class.hash("User@Example.COM")).to eq(described_class.hash("user@example.com"))
    end

    it "strips whitespace before hashing" do
      expect(described_class.hash("  user@example.com  ")).to eq(described_class.hash("user@example.com"))
    end

    it "returns nil when email is blank" do
      expect(described_class.hash(nil)).to be_nil
      expect(described_class.hash("")).to be_nil
    end
  end
end
