require "rails_helper"

describe Ctc::IncomeForm do
  describe "#save" do
    let(:params) do
      {
        timezone: "America/Chicago",
        had_reportable_income: "yes",
      }
    end
    let(:intake) { Intake::CtcIntake.new(visitor_id: "something", source: "some-source") }

    it "saves the timezone on the intake and creates a client, 2020 tax return and efile security information" do
      form = described_class.new(intake, params)

      expect {
        form.save
      }.to change(Client, :count).by(1).and change(TaxReturn, :count).by(1)

      intake = Intake.last
      expect(intake.timezone).to eq "America/Chicago"
      expect(intake.client).to be_present
      expect(intake.tax_returns.length).to eq 1
      expect(intake.tax_returns.first.year).to eq 2020
      expect(intake.tax_returns.first.is_ctc).to eq true
      expect(intake.visitor_id).to eq "something"
      expect(intake.source).to eq "some-source"
      expect(intake.type).to eq "Intake::CtcIntake"

      # .and change(EfileSecurityInformation, :count).by(1)
      # expect(intake.client.efile_security_information.ip_address).to eq "1.1.1.1"
      # expect(intake.client.efile_security_information.device_id).to eq "7BA1E530D6503F380F1496A47BEB6F33E40403D1"
      # expect(intake.client.efile_security_information.user_agent).to eq "GeckoFox"
      # expect(intake.client.efile_security_information.browser_language).to eq "en-US"
      # expect(intake.client.efile_security_information.platform).to eq "iPad"
      # expect(intake.client.efile_security_information.timezone_offset).to eq "+240"
      # expect(intake.client.efile_security_information.client_system_time).to eq "Mon Aug 02 2021 18:55:41 GMT-0400 (Eastern Daylight Time)"
    end
  end
end
