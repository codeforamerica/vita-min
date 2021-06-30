require "rails_helper"

describe Ctc::IncomeForm do
  context "validations" do
    let(:params) {
      {
        device_id: "7BA1E530D6503F380F1496A47BEB6F33E40403D1",
        user_agent: "GeckoFox",
        browser_language: "en-US",
        platform: "iPad",
        timezone_offset: "240",
        client_system_time: "Mon Aug 02 2021 18:55:41 GMT-0400 (Eastern Daylight Time)",
        ip_address: "1.1.1.1",
        timezone: "America/New_York"
      }
    }

    context "when all required information is provided" do
      it "is valid" do
        expect(described_class.new(Intake::CtcIntake.new, params)).to be_valid
      end
    end

    context "when efile security information fields are missing" do
      before do
        [:device_id, :user_agent, :browser_language, :platform, :timezone_offset, :client_system_time, :ip_address].each { |key| params.delete(key) }
      end

      it "is not valid" do
        form = described_class.new(Intake::CtcIntake.new, params)
        expect(form).not_to be_valid
        expect(form.errors.attribute_names).to match array_including(:device_id, :user_agent, :browser_language, :platform, :timezone_offset, :ip_address)
      end
    end
  end

  describe "#save" do
    let(:params) do
      {
        timezone: "America/Chicago",
        had_reportable_income: "yes",
        device_id: "7BA1E530D6503F380F1496A47BEB6F33E40403D1",
        user_agent: "GeckoFox",
        browser_language: "en-US",
        platform: "iPad",
        timezone_offset: "+240",
        client_system_time: "Mon Aug 02 2021 18:55:41 GMT-0400 (Eastern Daylight Time)",
        ip_address: "1.1.1.1",
      }
    end
    let(:intake) { Intake::CtcIntake.new(visitor_id: "something", source: "some-source") }

    it "saves the timezone and locale on the intake and creates a client, 2020 tax return and efile security information" do
      form = described_class.new(intake, params)

      expect {
        form.save
      }.to change(Client, :count).by(1).and change(TaxReturn, :count).by(1).and change(EfileSecurityInformation, :count).by(1)

      intake = Intake.last
      expect(intake.timezone).to eq "America/Chicago"
      expect(intake.locale).to eq "en"
      expect(intake.client).to be_present
      expect(intake.client.vita_partner.name).to eq "GetCTC.org (Site)"
      expect(intake.tax_returns.length).to eq 1
      expect(intake.tax_returns.first.year).to eq 2020
      expect(intake.tax_returns.first.is_ctc).to eq true
      expect(intake.visitor_id).to eq "something"
      expect(intake.source).to eq "some-source"
      expect(intake.type).to eq "Intake::CtcIntake"
      efile_security_information = intake.client.efile_security_informations.first
      expect(efile_security_information.ip_address).to eq "1.1.1.1"
      expect(efile_security_information.device_id).to eq "7BA1E530D6503F380F1496A47BEB6F33E40403D1"
      expect(efile_security_information.user_agent).to eq "GeckoFox"
      expect(efile_security_information.browser_language).to eq "en-US"
      expect(efile_security_information.platform).to eq "iPad"
      expect(efile_security_information.timezone_offset).to eq "+240"
      expect(efile_security_information.client_system_time).to eq "Mon Aug 02 2021 18:55:41 GMT-0400 (Eastern Daylight Time)"
    end
  end
end
