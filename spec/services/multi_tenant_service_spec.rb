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
      allow(Rails.application.config).to receive(:ctc_current_tax_year).and_return(2023)
    end

    it "returns just the current year for ctc and valid filing years for gyr when using DateTime.now" do
      fake_time = Rails.configuration.tax_year_filing_seasons[2020][1] + 3.years - 1.day
      Timecop.freeze(fake_time) do
        expect(described_class.new(:ctc).filing_years).to eq [2023]
        expect(described_class.new(:gyr).filing_years).to eq [2023, 2022, 2021, 2020]
      end
    end

    it "returns just the current year for ctc and valid filing years for gyr when passed a time parameter that is past the deadline for a previous year" do
      fake_time = Rails.configuration.tax_year_filing_seasons[2020][1] + 3.years + 1.day

      expect(described_class.new(:ctc).filing_years(fake_time)).to eq [2023]
      expect(described_class.new(:gyr).filing_years(fake_time)).to eq [2023, 2022, 2021]
    end

    context "during the 2025 GYR open season" do
      it "returns 2021, 2022, 2023, 2024" do
        fake_time = DateTime.parse("2025-02-14")

        expect(described_class.new(:gyr).filing_years(fake_time)).to eq [2024, 2023, 2022, 2021]
      end
    end

    context "GYR 2025 after tax deadline before end of in progress intake" do
      it "returns 2021, 2022, 2023, 2024" do
        fake_time = DateTime.parse("2025-06-23")

        expect(described_class.new(:gyr).filing_years(fake_time)).to eq [2024, 2023, 2022, 2021]
      end
    end

    context "GYR 2025 after end of in progress intake" do
      it "returns 2022, 2023, 2024" do
        fake_time = DateTime.parse("2025-12-21")

        expect(described_class.new(:gyr).filing_years(fake_time)).to eq [2024, 2023, 2022]
      end
    end
  end

  describe "#between_deadline_and_end_of_in_progress_intake?" do
    before do
      allow(Rails.configuration).to receive(:tax_deadline).and_return(Date.new(2025, 4, 15))
      allow(Rails.configuration).to receive(:end_of_in_progress_intake).and_return(Date.new(2025, 10, 15))
    end

    it "returns true when the date is between deadline and end of in progress intake" do
      Timecop.freeze(Date.new(2025, 4, 20)) do
        expect(described_class.new(:gyr).between_deadline_and_end_of_in_progress_intake?).to eq true
      end
    end

    it "returns false when the date is not between deadline and end of in progress intake" do
      Timecop.freeze(Date.new(2025, 10, 20)) do
        expect(described_class.new(:gyr).between_deadline_and_end_of_in_progress_intake?).to eq false
      end
    end
  end



  describe "#backtax_years" do
    before do
      allow(Rails.application.config).to receive(:ctc_current_tax_year).and_return(2017)
      allow(Rails.application.config).to receive(:gyr_current_tax_year).and_return(2018)
    end

    around do |example|
      Timecop.freeze(DateTime.parse("2019-04-14 12:00:00")) do
        example.run
      end
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
    end
  end

  describe "#twilio_status_webhook_url" do
    it "returns the twilio callback url except when statefile" do
      outgoing_message_id = create(:outgoing_text_message).id
      expect(described_class.new(:ctc).twilio_status_webhook_url(outgoing_message_id)).to eq twilio_update_status_url(outgoing_message_id, locale: nil)
      expect(described_class.new(:gyr).twilio_status_webhook_url(outgoing_message_id)).to eq twilio_update_status_url(outgoing_message_id, locale: nil)
      expect(described_class.new(:statefile).twilio_status_webhook_url(outgoing_message_id)).to be_nil
    end
  end
end