require "rails_helper"

RSpec.describe EnvironmentCredentials do
  describe ".[]" do
    let(:mock_credentials) do
      {
        mailgun: {
          api_key: "mailgun-key",
          domain: "mg.example.com",
        },
        twilio: {
          voice_phone_number: "+15551234567",
        },
        duplicate_hashing_key: "hash-key",
      }
    end

    before do
      allow(Rails.application).to receive(:credentials).and_return(mock_credentials)
      allow(ENV).to receive(:[]).and_call_original
    end

    context "when flipper flag is disabled (default)" do
      before do
        allow(Flipper).to receive(:enabled?).with(:use_env_secrets).and_return(false)
      end

      it "returns the value from Rails credentials" do
        expect(EnvironmentCredentials['MAILGUN_API_KEY']).to eq("mailgun-key")
      end

      it "returns the value for a single-level credential key" do
        expect(EnvironmentCredentials['DUPLICATE_HASHING_KEY']).to eq("hash-key")
      end

      it "returns nil for unknown keys" do
        expect(EnvironmentCredentials['NONEXISTENT_KEY']).to be_nil
      end

      it "returns nil when both ENV and credentials are missing" do
        expect(EnvironmentCredentials['MAILGUN_NONEXISTENT_KEY']).to be_nil
      end

      it "uses SECRET_KEYS mapping for non-obvious names" do
        allow(Rails.application).to receive(:credentials).and_return({ irs: { efin: "123456" } })
        expect(EnvironmentCredentials['VITA_MIN_EFIN']).to eq("123456")
      end
    end

    context "when flipper flag is enabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:use_env_secrets).and_return(true)
      end

      it "returns the value from ENV" do
        allow(ENV).to receive(:fetch).with('MAILGUN_API_KEY', nil).and_return("env-key")
        expect(EnvironmentCredentials['MAILGUN_API_KEY']).to eq("env-key")
      end

      it "returns nil when ENV value is not set (no credential fallback)" do
        allow(ENV).to receive(:[]).with('MAILGUN_API_KEY').and_return(nil)
        expect(EnvironmentCredentials['MAILGUN_API_KEY']).to be_nil
      end

      it "returns nil for unknown keys" do
        expect(EnvironmentCredentials['NONEXISTENT_KEY']).to be_nil
      end
    end
  end

  describe ".dig" do
    let(:mock_credentials) do
      {
        service_key: {
          test_key: "test-value",
        }
      }
    end

    context "when the key exists" do
      before do
        allow(Rails.application).to receive(:credentials).and_return(mock_credentials)
      end

      it "returns the value for the key" do
        expect(EnvironmentCredentials.dig(:service_key, :test_key)).to eq("test-value")
      end
    end

    context "when the key does not exist" do
      it "returns nil" do
        expect(EnvironmentCredentials.dig(:service_key, :nonexistent_key)).to be_nil
      end
    end

    context "when the parent key does not exist" do
      it "returns nil" do
        expect(EnvironmentCredentials.dig(:nonexistent_key, :test_key)).to be_nil
      end
    end
  end
end
