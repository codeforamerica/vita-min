require "rails_helper"

RSpec.describe EnvironmentCredentials do
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