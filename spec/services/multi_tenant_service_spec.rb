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
      allow(Rails.configuration).to receive(:statefile_url).and_return "https://fileyourstatetaxes.org"
    end
    it "creates a url based on the service name, locale, and passed path if any" do
      expect(described_class.new(:ctc).url(locale: "en")).to eq "https://getctc.org/en"
      expect(described_class.new(:gyr).url(locale: "es")).to eq "https://getyourrefund.org/es"
      expect(described_class.new(:statefile).url(locale: "en")).to eq "https://fileyourstatetaxes.org/en"
    end
  end

  describe "#current_tax_year" do
    before do
      allow(Rails.application.config).to receive(:ctc_current_tax_year).and_return(2017)
      allow(Rails.application.config).to receive(:gyr_current_tax_year).and_return(2018)
      allow(Rails.application.config).to receive(:statefile_current_tax_year).and_return(2023)
    end

    it "returns the specific config values for GYR & GetCTC" do
      expect(described_class.ctc.current_tax_year).to eq 2017
      expect(described_class.gyr.current_tax_year).to eq 2018
      expect(described_class.statefile.current_tax_year).to eq 2023
    end
  end

  describe "#end_of_current_tax_year" do
    before do
      allow(Rails.application.config).to receive(:statefile_current_tax_year).and_return(2023)
    end

    it "returns the last day of the tax year" do
      expect(described_class.new(:statefile).end_of_current_tax_year).to eq DateTime.new(2023).end_of_year
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

  describe "#intake_model" do
    it "returns the correct model for the service" do
      expect(described_class.new(:ctc).intake_model).to eq Intake::CtcIntake
      expect(described_class.new(:gyr).intake_model).to eq Intake::GyrIntake
      expect {
        described_class.new(:statefile).intake_model
      }.to raise_error StandardError
      expect(described_class.new(:statefile_az).intake_model).to eq StateFileAzIntake
      expect(described_class.new(:statefile_ny).intake_model).to eq StateFileNyIntake
    end
  end
end