require 'rails_helper'

describe SubmissionBuilder::ReturnHeader do
  StateFile::StateInformationService.active_state_codes.each do |state_code|
    describe '.document' do
      let(:intake) { create "state_file_#{state_code}_intake".to_sym }
      let(:submission) { create(:efile_submission, data_source: intake) }
      let(:doc) { SubmissionBuilder::ReturnHeader.new(submission).document }

      context "misc basic attributes" do
        let(:mailing_street) { "1234 Main Street" }
        let(:mailing_apartment) { "B" }
        let(:mailing_city) { "Citayy" }
        let(:mailing_zip) { "54321" }
        let(:tax_return_year) { 2024 }
        let(:efin) { "123455" }
        let(:sin) { "223455" }
        before do
          intake.direct_file_data.mailing_street = mailing_street
          intake.direct_file_data.mailing_apartment = mailing_apartment
          intake.direct_file_data.mailing_city = mailing_city
          intake.direct_file_data.mailing_zip = mailing_zip
          intake.direct_file_data.tax_return_year = tax_return_year
          allow(EnvironmentCredentials).to receive(:irs).with(:efin).and_return efin
          allow(EnvironmentCredentials).to receive(:irs).with(:sin).and_return sin
        end

        it "generates xml with the right values" do
          expect(doc.at("Jurisdiction").text).to eq "#{state_code.upcase}ST"
          expect(doc.at("ReturnTs").text).to eq submission.created_at.strftime("%FT%T%:z")
          expect(doc.at("TaxPeriodBeginDt").text).to eq Date.new(tax_return_year, 1, 1).strftime("%F")
          expect(doc.at("TaxPeriodEndDt").text).to eq Date.new(tax_return_year, 12, 31).strftime("%F")
          expect(doc.at("TaxYr").text).to eq tax_return_year.to_s
          expect(doc.at("OriginatorGrp EFIN").text).to eq efin
          expect(doc.at("OriginatorGrp OriginatorTypeCd").text).to eq "OnlineFiler"
          expect(doc.at("SoftwareId").text).to eq sin
          expect(doc.at("ReturnType").text).to eq StateFile::StateInformationService.return_type(state_code)
          expect(doc.at("USAddress AddressLine1Txt").text).to eq mailing_street
          expect(doc.at("USAddress AddressLine2Txt").text).to eq mailing_apartment
          expect(doc.at("USAddress CityNm").text).to eq mailing_city
          expect(doc.at("USAddress StateAbbreviationCd").text).to eq state_code.upcase
          expect(doc.at("USAddress ZIPCd").text).to eq mailing_zip
        end
      end

      context "filer personal info" do
        let(:intake) {
          create(
            "state_file_#{state_code}_intake".to_sym,
            filing_status: filing_status,
            primary_birth_date: primary_birth_date,
            primary_first_name: primary_first_name,
            primary_middle_initial: primary_middle_initial,
            primary_last_name: primary_last_name,
            spouse_first_name: spouse_first_name,
            spouse_birth_date: spouse_birth_date,
            spouse_middle_initial: spouse_middle_initial,
            spouse_last_name: spouse_last_name,
          )
        }
        let(:primary_birth_date) { 40.years.ago }
        let(:primary_ssn) { "100000030" }
        let(:primary_first_name) { "Prim" }
        let(:primary_middle_initial) { "W" }
        let(:primary_last_name) { "Filerton" }
        let(:spouse_birth_date) { nil }
        let(:spouse_ssn) { nil }
        let(:spouse_first_name) { nil }
        let(:spouse_middle_initial) { nil }
        let(:spouse_last_name) { nil }
        before do
          intake.direct_file_data.primary_ssn = primary_ssn
          intake.direct_file_data.spouse_ssn = spouse_ssn
        end

        context "single filer" do
          let(:filing_status) { "single" }

          it "generates xml with primary filer DOB only" do
            expect(doc.at("Filer Primary DateOfBirth").text).to eq primary_birth_date.strftime("%F")
            expect(doc.at('Filer Primary TaxpayerSSN').content).to eq primary_ssn
            expect(doc.at('Filer Primary TaxpayerName FirstName').content).to eq primary_first_name
            expect(doc.at('Filer Primary TaxpayerName MiddleInitial').content).to eq primary_middle_initial
            expect(doc.at('Filer Primary TaxpayerName LastName').content).to eq primary_last_name

            expect(doc.at("Filer Secondary DateOfBirth")).not_to be_present
            expect(doc.at('Filer Secondary TaxpayerSSN')).not_to be_present
            expect(doc.at('Filer Secondary TaxpayerName FirstName')).not_to be_present
            expect(doc.at('Filer Secondary TaxpayerName MiddleInitial')).not_to be_present
            expect(doc.at('Filer Secondary TaxpayerName LastName')).not_to be_present
          end
        end

        context "filer with spouse" do
          let(:filing_status) { "married_filing_jointly" }
          let(:spouse_birth_date) { 42.years.ago }
          let(:spouse_ssn) { "200000030" }
          let(:spouse_first_name) { "Sec" }
          let(:spouse_middle_initial) { "Z" }
          let(:spouse_last_name) { "Filerton" }

          it "generates xml with primary and spouse DOBs" do
            expect(doc.at("Filer Primary DateOfBirth").text).to eq primary_birth_date.strftime("%F")

            expect(doc.at("Filer Secondary DateOfBirth").text).to eq spouse_birth_date.strftime("%F")
            expect(doc.at('Filer Secondary TaxpayerSSN').content).to eq spouse_ssn
            expect(doc.at('Filer Secondary TaxpayerName FirstName').content).to eq spouse_first_name
            expect(doc.at('Filer Secondary TaxpayerName MiddleInitial').content).to eq spouse_middle_initial
            expect(doc.at('Filer Secondary TaxpayerName LastName').content).to eq spouse_last_name
          end
        end
      end
    end
  end
end
