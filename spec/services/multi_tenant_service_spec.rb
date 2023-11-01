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
      allow(Rails.configuration).to receive(:state_file_url).and_return "https://fileyourstatestaxes.org"
    end
    it "creates a url based on the service name, locale, and passed path if any" do
      expect(described_class.new(:ctc).url(locale: "en")).to eq "https://getctc.org/en"
      expect(described_class.new(:gyr).url(locale: "es")).to eq "https://getyourrefund.org/es"
      expect(described_class.new(:statefile).url(locale: "en")).to eq "https://fileyourstatestaxes.org/en"
    end
  end

  describe "#current_tax_year" do
    before do
      allow(Rails.application.config).to receive(:ctc_current_tax_year).and_return(2017)
      allow(Rails.application.config).to receive(:gyr_current_tax_year).and_return(2018)
    end

    it "returns the specific config values for GYR & GetCTC" do
      expect(described_class.new(:ctc).current_tax_year).to eq 2017
      expect(described_class.new(:gyr).current_tax_year).to eq 2018
    end
  end

  describe "#prior_tax_year" do
    before do
      allow(Rails.application.config).to receive(:ctc_current_tax_year).and_return(2017)
      allow(Rails.application.config).to receive(:gyr_current_tax_year).and_return(2018)
    end

    it "returns the prior years for ctc and gyr given the current tax years" do
      expect(described_class.new(:ctc).prior_tax_year).to eq 2016
      expect(described_class.new(:gyr).prior_tax_year).to eq 2017
    end
  end

  describe "#filing_years" do
    before do
      allow(Rails.application.config).to receive(:ctc_current_tax_year).and_return(2017)
      allow(Rails.application.config).to receive(:gyr_current_tax_year).and_return(2018)
    end

    it "returns just the current year for ctc and 4 years for gyr" do
      expect(described_class.new(:ctc).filing_years).to eq [2017]
      expect(described_class.new(:gyr).filing_years).to eq [2018, 2017, 2016, 2015]
    end
  end

  describe "#backtax_years" do
    before do
      allow(Rails.application.config).to receive(:ctc_current_tax_year).and_return(2017)
      allow(Rails.application.config).to receive(:gyr_current_tax_year).and_return(2018)
    end

    it "returns just the current year for ctc and 4 years for gyr" do
      expect(described_class.new(:ctc).backtax_years).to eq []
      expect(described_class.new(:gyr).backtax_years).to eq [2017, 2016, 2015]
    end
  end
end