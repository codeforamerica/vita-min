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

  describe "Sentry reporting for credentials-sourced reads" do
    let(:mock_credentials) do
      {
        mailgun: {
          api_key: "mailgun-key",
        },
      }
    end

    before do
      allow(Rails.application).to receive(:credentials).and_return(mock_credentials)
      allow(Flipper).to receive(:enabled?).with(:use_env_secrets).and_return(false)
      allow(Sentry).to receive(:initialized?).and_return(true)
      allow(Sentry).to receive(:capture_message)
      allow(ENV).to receive(:[]).and_call_original
      described_class::REPORTED_CREDENTIALS_READS.clear
    end

    it "reports the secret name at warning level when ENV has no value" do
      allow(ENV).to receive(:[]).with('MAILGUN_API_KEY').and_return(nil)

      EnvironmentCredentials['MAILGUN_API_KEY']

      expect(Sentry).to have_received(:capture_message).with(
        a_string_including("MAILGUN_API_KEY", "MISSING from ENV"),
        level: :warning
      )
    end

    it "reports at info level when ENV also has the value" do
      allow(ENV).to receive(:[]).with('MAILGUN_API_KEY').and_return("env-key")

      EnvironmentCredentials['MAILGUN_API_KEY']

      expect(Sentry).to have_received(:capture_message).with(
        a_string_including("MAILGUN_API_KEY", "also present in ENV"),
        level: :info
      )
    end

    it "reports only once per secret per process" do
      3.times { EnvironmentCredentials['MAILGUN_API_KEY'] }

      expect(Sentry).to have_received(:capture_message).once
    end

    it "does not report when credentials have no value for the name" do
      EnvironmentCredentials['NONEXISTENT_KEY']

      expect(Sentry).not_to have_received(:capture_message)
    end

    it "does not report when the flag routes the read to ENV" do
      allow(Flipper).to receive(:enabled?).with(:use_env_secrets).and_return(true)

      EnvironmentCredentials['MAILGUN_API_KEY']

      expect(Sentry).not_to have_received(:capture_message)
    end

    it "stays quiet, and does not raise, before Sentry is initialized" do
      allow(Sentry).to receive(:initialized?).and_return(false)

      expect { EnvironmentCredentials['MAILGUN_API_KEY'] }.not_to raise_error
      expect(Sentry).not_to have_received(:capture_message)
    end

    it "reports the credentials fallback in .irs, which ignores the flag" do
      allow(Rails.application).to receive(:credentials).and_return({ irs: { efin: "123456" } })
      allow(ENV).to receive(:[]).with('VITA_MIN_EFIN').and_return(nil)

      expect(EnvironmentCredentials.irs(:efin)).to eq("123456")
      expect(Sentry).to have_received(:capture_message).with(
        a_string_including("VITA_MIN_EFIN"),
        level: :warning
      )
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
