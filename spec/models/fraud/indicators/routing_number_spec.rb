require "rails_helper"

describe Fraud::Indicators::RoutingNumber do
  describe "#riskylist" do
    before do
      described_class.create(routing_number: "123456789", bank_name: "Bank of Taxes", activated_at: DateTime.now)
      described_class.create(routing_number: "111111111", bank_name: "Bank of Money", activated_at: DateTime.now)
      described_class.create(routing_number: "111111111", bank_name: "Bank of Things", activated_at: nil)
      allow(EnvironmentCredentials).to receive(:dig).with(:duplicate_hashing_key).and_return "1"
    end

    it "converts entries into a list of their hashed versions" do
      expect(described_class.riskylist).to eq ["4e1cbd2bad5ec1241a99af0ad298c080fc1358c9aba120e33d73a9c96d4445c6", "ebbcb9796f3f6e771f0599ea197d212c34050b8040eb565830514694eec035d0"]
    end
  end
end