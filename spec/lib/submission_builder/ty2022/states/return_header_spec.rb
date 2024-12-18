require 'rails_helper'

describe SubmissionBuilder::ReturnHeader do
  StateFile::StateInformationService.active_state_codes.each do |state_code|
    describe ".document for #{state_code}" do
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
          software_id = StateFile::StateInformationService.software_id_key(state_code).to_sym
          allow(EnvironmentCredentials).to receive(:irs).with(software_id).and_return sin
        end

        it "generates xml with the right values" do
          expect(doc.at("Jurisdiction").text).to eq "#{state_code.upcase}ST"
          expect(doc.at("ReturnTs").text).to eq submission.created_at.strftime("%FT%T%:z")
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

      context "paid preparer information group" do
        if state_code == "nj"
          context "for NJ returns" do
            it "adds XML elements for PaidPreparerInformationGrp" do
              expect(doc.at("PaidPreparerInformationGrp PTIN").text).to eq "P99999999"
              expect(doc.at("PaidPreparerInformationGrp PreparerPersonNm").text).to eq "Self Prepared"
            end
          end
        else
          context "for non NJ returns" do
            it "does not add XML elements for PaidPreparerInformationGrp" do
              expect(doc.at("PaidPreparerInformationGrp")).not_to be_present 
              expect(doc.at("PaidPreparerInformationGrp PTIN")).not_to be_present 
              expect(doc.at("PaidPreparerInformationGrp PreparerPersonNm")).not_to be_present 
            end
          end
        end
      end

      context "filer personal info" do
        let(:primary_birth_date) { 40.years.ago }
        let(:primary_ssn) { "100000030" }
        let(:primary_first_name) { "Prim" }
        let(:primary_middle_initial) { "W" }
        let(:primary_last_name) { "Filerton" }
        let(:primary_suffix) { "JR" }
        let(:primary_esigned_at) { DateTime.new(2024, 12, 19, 12) }
        let(:primary_esigned) { 'yes' }

        let(:spouse_birth_date) { nil }
        let(:spouse_ssn) { nil }
        let(:spouse_first_name) { nil }
        let(:spouse_middle_initial) { nil }
        let(:spouse_last_name) { nil }
        let(:spouse_suffix) { nil }
        let(:spouse_esigned_at) { nil }
        let(:spouse_esigned) { 'unfilled' }

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

        before do
          intake.direct_file_data.primary_ssn = primary_ssn
          intake.primary_suffix = primary_suffix
          intake.primary_esigned = primary_esigned
          intake.primary_esigned_at = primary_esigned_at
          intake.direct_file_data.spouse_ssn = spouse_ssn
          intake.direct_file_data.phone_number = "5551231234"
          intake.spouse_suffix = spouse_suffix
          intake.spouse_esigned = spouse_esigned
          intake.spouse_esigned_at = spouse_esigned_at
        end

        context "single filer" do
          let(:filing_status) { "single" }

          it "generates xml with primary filer DOB only" do
            expect(doc.at("Filer Primary DateOfBirth").text).to eq primary_birth_date.strftime("%F")
            expect(doc.at('Filer Primary TaxpayerSSN').content).to eq primary_ssn
            expect(doc.at('Filer Primary TaxpayerName FirstName').content).to eq primary_first_name
            expect(doc.at('Filer Primary TaxpayerName MiddleInitial').content).to eq primary_middle_initial
            expect(doc.at('Filer Primary TaxpayerName LastName').content).to eq primary_last_name
            expect(doc.at('Filer Primary TaxpayerName NameSuffix').content).to eq primary_suffix
            expect(doc.at("Filer Primary USPhone").text).to eq "5551231234"
            expect(doc.at('Filer Primary DateSigned').text).to eq '2024-12-19'

            expect(doc.at("Filer Secondary DateOfBirth")).not_to be_present
            expect(doc.at('Filer Secondary TaxpayerSSN')).not_to be_present
            expect(doc.at('Filer Secondary TaxpayerName FirstName')).not_to be_present
            expect(doc.at('Filer Secondary TaxpayerName MiddleInitial')).not_to be_present
            expect(doc.at('Filer Secondary TaxpayerName LastName')).not_to be_present
            expect(doc.at('Filer Secondary TaxpayerName NameSuffix')).not_to be_present
            expect(doc.at('Filer Secondary DateSigned')).not_to be_present
          end

          context "excluding absent fields" do
            let(:primary_birth_date) { nil }
            let(:primary_ssn) { nil }
            let(:primary_first_name) { nil }
            let(:primary_middle_initial) { nil }
            let(:primary_last_name) { nil }
            let(:primary_esigned) { 'unfilled' }
            let(:primary_esigned_at) { nil }

            before do
              intake.direct_file_data.primary_ssn = nil
              intake.direct_file_data.spouse_ssn = nil
              intake.direct_file_data.phone_number = nil

              if intake.direct_file_json_data&.primary_filer.present?
                intake.direct_file_json_data.primary_filer.dob = nil
                intake.direct_file_json_data.primary_filer.first_name = nil
                intake.direct_file_json_data.primary_filer.middle_initial = nil
                intake.direct_file_json_data.primary_filer.last_name = nil
                intake.primary_suffix = primary_suffix
              end

              if intake.direct_file_json_data&.spouse_filer.present?
                intake.direct_file_json_data.spouse_filer.dob = nil
                intake.direct_file_json_data.spouse_filer.first_name = nil
                intake.direct_file_json_data.spouse_filer.middle_initial = nil
                intake.direct_file_json_data.spouse_filer.first_name = nil
                intake.spouse_suffix = nil
              end

              intake.synchronize_filers_to_database
            end

            it "excludes fields when they are empty" do
              expect(doc.at("Filer Primary DateOfBirth")).not_to be_present
              expect(doc.at('Filer Primary TaxpayerSSN')).not_to be_present
              expect(doc.at('Filer Primary TaxpayerName FirstName')).not_to be_present
              expect(doc.at('Filer Primary TaxpayerName MiddleInitial')).not_to be_present
              expect(doc.at('Filer Primary TaxpayerName LastName')).not_to be_present
              expect(doc.at('Filer Primary TaxpayerName NameSuffix')).not_to be_present
              expect(doc.at("Filer Primary USPhone")).not_to be_present
              expect(doc.at("Filer Primary DateSigned")).not_to be_present

              expect(doc.at("Filer Secondary DateOfBirth")).not_to be_present
              expect(doc.at('Filer Secondary TaxpayerSSN')).not_to be_present
              expect(doc.at('Filer Secondary TaxpayerName FirstName')).not_to be_present
              expect(doc.at('Filer Secondary TaxpayerName MiddleInitial')).not_to be_present
              expect(doc.at('Filer Secondary TaxpayerName LastName')).not_to be_present
              expect(doc.at('Filer Secondary TaxpayerName NameSuffix')).not_to be_present
              expect(doc.at("Filer Secondary DateSigned")).not_to be_present
            end
          end
        end

        context "filer with spouse" do
          let(:filing_status) { "married_filing_jointly" }
          let(:spouse_birth_date) { 42.years.ago }
          let(:spouse_ssn) { "200000030" }
          let(:spouse_first_name) { "Sec" }
          let(:spouse_middle_initial) { "Z" }
          let(:spouse_last_name) { "Filerton" }
          let(:spouse_suffix) { "SR" }
          let(:spouse_esigned_at) { DateTime.new(2024, 12, 18, 12) }
          let(:spouse_esigned) { 'yes' }

          it "generates xml with primary and spouse DOBs" do
            expect(doc.at("Filer Primary DateOfBirth").text).to eq primary_birth_date.strftime("%F")
            expect(doc.at('Filer Primary DateSigned').text).to eq '2024-12-19'

            expect(doc.at("Filer Secondary DateOfBirth").text).to eq spouse_birth_date.strftime("%F")
            expect(doc.at('Filer Secondary TaxpayerSSN').content).to eq spouse_ssn
            expect(doc.at('Filer Secondary TaxpayerName FirstName').content).to eq spouse_first_name
            expect(doc.at('Filer Secondary TaxpayerName MiddleInitial').content).to eq spouse_middle_initial
            expect(doc.at('Filer Secondary TaxpayerName LastName').content).to eq spouse_last_name
            expect(doc.at('Filer Secondary TaxpayerName NameSuffix').content).to eq spouse_suffix
            expect(doc.at('Filer Secondary DateSigned').text).to eq '2024-12-18'
          end

          context "filers have lower cased suffixes" do
            let(:primary_suffix) { "Jr" }
            let(:spouse_suffix) { "sr" }

            it "should upcase suffixes" do
              expect(doc.at("Filer Primary TaxpayerName NameSuffix").text).to eq("JR")
              expect(doc.at("Filer Secondary TaxpayerName NameSuffix").text).to eq("SR")
            end
          end

          context "married filing separately" do
            let(:filing_status) { "married_filing_separately" }

            it "does not include secondary xml (spouse)" do
              expect(doc.at("Filer Secondary DateOfBirth")).not_to be_present
              expect(doc.at('Filer Secondary TaxpayerSSN')).not_to be_present
              expect(doc.at('Filer Secondary TaxpayerName FirstName')).not_to be_present
              expect(doc.at('Filer Secondary TaxpayerName MiddleInitial')).not_to be_present
              expect(doc.at('Filer Secondary TaxpayerName LastName')).not_to be_present
              expect(doc.at('Filer Secondary TaxpayerName NameSuffix')).not_to be_present
              expect(doc.at('Filer Secondary DateSigned')).not_to be_present
            end
          end
        end
      end
    end
  end

  context "tax period information" do
    let(:tax_return_year) { 2024 }
    before do
      intake.direct_file_data.tax_return_year = tax_return_year
    end

    StateFile::StateInformationService.active_state_codes.without("nc").each do |state_code|
      context "if state is not NC" do
        let(:intake) { create "state_file_#{state_code}_intake".to_sym }
        let(:submission) { create(:efile_submission, data_source: intake) }
        let(:doc) { SubmissionBuilder::ReturnHeader.new(submission).document }
        it "shows tax period information" do
          expect(doc.at("TaxPeriodBeginDt").text).to eq Date.new(tax_return_year, 1, 1).strftime("%F")
          expect(doc.at("TaxPeriodEndDt").text).to eq Date.new(tax_return_year, 12, 31).strftime("%F")
        end
      end
    end
    context "if state is NC" do
      let(:intake) { create :state_file_nc_intake }
      let(:submission) { create(:efile_submission, data_source: intake) }
      let(:doc) { SubmissionBuilder::ReturnHeader.new(submission).document }
      it "does not show tax period information" do
        expect(doc.at("TaxPeriodBeginDt")).to be_nil
        expect(doc.at("TaxPeriodEndDt")).to be_nil
      end
    end
  end

  context "city field character limit" do
    let(:mailing_city) { "This is a Very Long City Name" }

    before do
      intake.direct_file_data.mailing_city = mailing_city
    end

    StateFile::StateInformationService.active_state_codes.without("md").each do |state_code|
      context "if state is not MD" do
        let(:intake) { create "state_file_#{state_code}_intake".to_sym }
        let(:submission) { create(:efile_submission, data_source: intake) }
        let(:doc) { SubmissionBuilder::ReturnHeader.new(submission).document }

        it "truncates city name to 22 characters" do
          expect(doc.at("USAddress CityNm").text.length).to be 22
          expect(doc.at("USAddress CityNm").text).to eq('This is a Very Long Ci')
        end
      end
    end

    context "if state is MD" do
      let(:intake) { create :state_file_md_intake }
      let(:submission) { create(:efile_submission, data_source: intake) }
      let(:doc) { SubmissionBuilder::ReturnHeader.new(submission).document }

      it "truncates city name to 20 characters" do
        expect(doc.at("USAddress CityNm").text.length).to be 19
        expect(doc.at("USAddress CityNm").text).to eq('This is a Very Long')
      end
    end
  end

  context "MD filer personal info includes signature PINs" do
    let(:intake) {
      create(
        :state_file_md_intake,
        filing_status: filing_status,
        primary_signature_pin: primary_signature_pin,
        primary_esigned: primary_esigned,
        primary_esigned_at: primary_esigned_at,
        spouse_signature_pin: spouse_signature_pin,
        spouse_esigned: spouse_esigned,
        spouse_esigned_at: spouse_esigned_at
      )
    }
    let(:tomorrow_midnight) { DateTime.tomorrow.beginning_of_day }
    let(:primary_signature_pin) { "12345" }
    let(:primary_esigned) { "yes" }
    let(:primary_esigned_at) { tomorrow_midnight }
    let(:spouse_signature_pin) { "23456" }
    let(:spouse_esigned) { "yes" }
    let(:spouse_esigned_at) { tomorrow_midnight }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:doc) { SubmissionBuilder::ReturnHeader.new(submission).document }

    context "single filer" do
      let(:filing_status) { "single" }

      it "generates xml with primary signature PIN only" do
        expect(doc.at('Filer Primary TaxpayerPIN').content).to eq primary_signature_pin
        expect(doc.at('Filer Secondary TaxpayerPIN')).not_to be_present
      end

      it "handles timezone correctly for signature date when the filer esigns after midnight UTC but not after midnight in the State's timezone" do
        expect(doc.at('Filer Primary DateSigned').content).to eq tomorrow_midnight.in_time_zone("America/New_York").strftime("%Y-%m-%d")
        expect(doc.at('Filer Secondary DateSigned')).not_to be_present
      end
    end

    context "filer with spouse" do
      let(:filing_status) { "married_filing_jointly" }

      before do
        intake.spouse_first_name = "Secondary"
        intake.direct_file_data.spouse_ssn = "200000030"
      end

      it "generates xml with primary and spouse signature PINs" do
        expect(doc.at('Filer Primary TaxpayerPIN').content).to eq primary_signature_pin
        expect(doc.at('Filer Secondary TaxpayerPIN').content).to eq spouse_signature_pin
      end

      it "it correctly signs with the date of the correct timezone when the filer esigns after midnight UTC but not after midnight in the State's timezone" do
        expect(doc.at('Filer Primary DateSigned').content).to eq tomorrow_midnight.in_time_zone("America/New_York").strftime("%Y-%m-%d")
        expect(doc.at('Filer Secondary DateSigned').content).to eq tomorrow_midnight.in_time_zone("America/New_York").strftime("%Y-%m-%d")
      end
    end
  end

  context "Disaster relief" do
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:doc) { SubmissionBuilder::ReturnHeader.new(submission).document }

    context "NC intake" do
      let(:intake) {
        create(
          :state_file_nc_intake,
          residence_county: "001", # Alamance county - non designated
          moved_after_hurricane_helene: "yes",
          county_during_hurricane_helene: "011" # Buncombe county - designated
        )
      }

      it "generates the return header with the DisasterReliefTxt xml" do
        expect(doc.at('DisasterReliefTxt')).to be_present
        expect(doc.at('DisasterReliefTxt').content).to eq "Alamance_Helene;Buncombe_Helene"
      end
    end

    context "AZ intake" do
      let(:intake) { create(:state_file_az_intake,) }
      it "does not include disaster relief xml" do
        expect(doc.at('DisasterReliefTxt')).not_to be_present
      end
    end
  end
end
