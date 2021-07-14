require "rails_helper"

describe MultiTenantService do
  context 'initialization' do
    context "when the service_type is not included on the list" do
      it "raises an argument error" do
        expect {
          described_class.new("something_random")
        }.to raise_error ArgumentError
      end
    end
  end

  describe "#url" do
    before do
      allow(Rails.configuration).to receive(:ctc_url).and_return "https://getctc.org"
      allow(Rails.configuration).to receive(:gyr_url).and_return "https://getyourrefund.org"
    end
    it "creates a url based on the service name, locale, and passed path if any" do
      expect(described_class.new(:ctc).url(locale: "en")).to eq "https://getctc.org/en"

      expect(described_class.new(:gyr).url(locale: "es")).to eq "https://getyourrefund.org/es"

    end
  end
end