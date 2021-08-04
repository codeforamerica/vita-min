require "rails_helper"

describe Ctc::ConsentForm do
  let(:intake) { Intake::CtcIntake.new(visitor_id: "something", source: "some-source") }

  context "validations" do
    let(:params) {
      {
        primary_first_name: "Marty",
        primary_middle_initial: "J",
        primary_last_name: "Mango",
        primary_birth_date_year: "1963",
        primary_birth_date_month: "9",
        primary_birth_date_day: "10",
        primary_ssn: "111-22-8888",
        primary_ssn_confirmation: "111-22-8888",
        phone_number: "831-234-5678",
        timezone: "America/Chicago",
        primary_tin_type: "ssn",
        device_id: "7BA1E530D6503F380F1496A47BEB6F33E40403D1",
        user_agent: "GeckoFox",
        browser_language: "en-US",
        platform: "iPad",
        timezone_offset: "240",
        client_system_time: "Mon Aug 02 2021 18:55:41 GMT-0400 (Eastern Daylight Time)",
      }
    }
    context "when all required information is provided" do
      it "is valid" do
        expect(described_class.new(intake, params)).to be_valid
      end
    end

    context "when first name is not provided" do
      before do
        params[:primary_first_name] = nil
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when the names contain characters outside the allowed set" do
      before do
        params[:primary_first_name] = "sunshine😍"
        params[:primary_middle_initial] = "🍩"
        params[:primary_last_name] = "rainbow🌈"
      end

      it "is not valid" do
        form = described_class.new(intake, params)
        expect(form).to_not be_valid
        expect(form.errors.keys).to include(:primary_first_name, :primary_middle_initial, :primary_last_name)
      end
    end

    context "when the names contain characters that can be transliterated to A-Z" do
      before do
        params[:primary_first_name] = "Josè"
      end

      it "is valid" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
      end
    end

    context "when last name is not provided" do
      before do
        params[:primary_last_name] = nil
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when itin format is correct" do
      before do
        params[:primary_tin_type] = "itin"
        params[:primary_ssn] = "999-87-9999"
        params[:primary_ssn_confirmation] = "999-87-9999"
      end

      it "it is valid" do
        expect(described_class.new(intake, params)).to be_valid
      end
    end

    context "when ssn format is not correct" do
      before do
        params[:primary_tin_type] = "ssn"
        params[:primary_ssn] = "666-99-9999"
        params[:primary_ssn_confirmation] = "666-99-9999"
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).to_not be_valid
      end
    end

    context "when itin format is not correct" do
      before do
        params[:primary_tin_type] = "itin"
        params[:primary_ssn] = "900-69-0000"
        params[:primary_ssn_confirmation] = "900-69-0000"
      end

      it "it not valid" do
        expect(described_class.new(intake, params)).to_not be_valid
      end
    end

    context "when ssn does not match confirmation" do
      before do
        params[:primary_ssn_confirmation] = "222-44-8888"
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when ssn is not confirmed" do
      before do
        params[:primary_ssn_confirmation] = nil
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when phone number is not valid" do
      before do
        params[:phone_number] = "555-123-4567"
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when phone number is not present" do
      before do
        params[:phone_number] = nil
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when the birth date is missing a number" do
      before do
        params[:primary_birth_date_month] = nil
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when the birth date is not a valid date" do
      before do
        params[:primary_birth_date_month] = "14"
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end
  end

  describe "#save" do
    it "saves the attributes on the intake and creates a client, 2020 tax return and efile security information" do
      form = described_class.new(intake, {
          primary_first_name: "Marty",
          primary_middle_initial: "J",
          primary_last_name: "Mango",
          primary_birth_date_year: "1963",
          primary_birth_date_month: "9",
          primary_birth_date_day: "10",
          primary_ssn: "111-22-8888",
          primary_ssn_confirmation: "111-22-8888",
          phone_number: "831-234-5678",
          timezone: "America/Chicago",
          primary_tin_type: :itin,
          device_id: "7BA1E530D6503F380F1496A47BEB6F33E40403D1",
          user_agent: "GeckoFox",
          browser_language: "en-US",
          platform: "iPad",
          timezone_offset: "240",
          client_system_time: "Mon Aug 02 2021 18:55:41 GMT-0400 (Eastern Daylight Time)",
      })
      expect {
        form.valid? # the form only transforms the phone number if it is validated before calling save
        form.save
      }.to change(Client, :count).by(1).and change(TaxReturn, :count).by(1).and change(Client::EfileSecurityInformation, :count).by(1)
      intake = Intake.last
      expect(intake.primary_first_name).to eq "Marty"
      expect(intake.primary_middle_initial).to eq "J"
      expect(intake.primary_last_name).to eq "Mango"
      expect(intake.primary_birth_date).to eq Date.new(1963, 9, 10)
      expect(intake.primary_ssn).to eq "111228888"
      expect(intake.phone_number).to eq "+18312345678"
      expect(intake.primary_last_four_ssn).to eq "8888"
      expect(intake.timezone).to eq "America/Chicago"
      expect(intake.client).to be_present
      expect(intake.tax_returns.length).to eq 1
      expect(intake.tax_returns.first.year).to eq 2020
      expect(intake.tax_returns.first.is_ctc).to eq true
      expect(intake.primary_tin_type).to eq "itin"
      expect(intake.visitor_id).to eq "something"
      expect(intake.source).to eq "some-source"
      expect(intake.type).to eq "Intake::CtcIntake"
      # TODO: Expect IP address also
      expect(intake.client.efile_security_information.device_id).to eq "7BA1E530D6503F380F1496A47BEB6F33E40403D1"
      expect(intake.client.efile_security_information.user_agent).to eq "GeckoFox"
      expect(intake.client.efile_security_information.browser_language).to eq "en-US"
      expect(intake.client.efile_security_information.platform).to eq "iPad"
      expect(intake.client.efile_security_information.timezone_offset).to eq "+240"
      expect(intake.client.efile_security_information.client_system_time).to eq "Mon Aug 02 2021 18:55:41 GMT-0400 (Eastern Daylight Time)"
      expect(form.intake).to eq intake # resets intake to be the created and persisted intake
    end
  end
end
