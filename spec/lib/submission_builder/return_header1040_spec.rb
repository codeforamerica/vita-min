require "rails_helper"

describe SubmissionBuilder::ReturnHeader1040 do
  describe ".build" do
    let(:fake_time) { DateTime.new(2021, 4, 21) }
    before do
      submission.intake.update(
        primary_first_name: "Hubert Blaine ",
        primary_last_name: "Di Wolfeschlegelsteinhausenbergerdorff ",
        spouse_first_name: "Lisa",
        spouse_last_name: "Frank",
        primary_signature_pin: "12345",
        spouse_signature_pin: "54321",
        spouse_filed_prior_tax_year: "did_not_file",
        primary_signature_pin_at: DateTime.new(2021, 4, 20, 16, 20),
        spouse_signature_pin_at: DateTime.new(2021, 4, 20, 16, 20),
        primary_prior_year_agi_amount: 10000
      )
      submission.client.update!(
        created_at: DateTime.new(2021, 4, 20, 12, 0),
        # Current session has lasted 1 minute
        current_sign_in_at: DateTime.new(2021, 4, 20, 16, 20),
        last_seen_at: DateTime.new(2021, 4, 20, 16, 21),
        # Previous sessions have lasted 20 minutes
        previous_sessions_active_seconds: 20 * 60,
      )

      create(:efile_security_information, efile_submission_id: submission.id, client: submission.client)
      expect(submission.client.efile_security_informations.count).to eq(2)
    end

    let(:submission) { create :efile_submission, :ctc, filing_status: filing_status, tax_year: 2021 }
    let(:filing_status) { "married_filing_jointly" }

    context "when the XML is valid" do
      let(:file_double) { double }
      let(:schema_double) { double }
      let(:submission) { create :efile_submission, :ctc }

      before do
        allow(File).to receive(:open).and_return(file_double)
        allow(Nokogiri::XML).to receive(:Schema).with(file_double).and_return(schema_double)
        allow(schema_double).to receive(:validate).and_return([])
      end

      it "returns an Efile::Response object that responds to #valid? and contains no errors and provides the created Nokogiri object" do
        response = described_class.build(submission)
        expect(response).to be_an_instance_of SubmissionBuilder::Response
        expect(response).to be_valid
        expect(response.errors).to eq []
        expect(response.document).to be_an_instance_of Nokogiri::XML::Document
      end
    end

    context "when the XML is not valid against the schema" do
      let(:file_double) { double }
      let(:schema_double) { double }
      before do
        allow(File).to receive(:open).and_return(file_double)
        allow(Nokogiri::XML).to receive(:Schema).with(file_double).and_return(schema_double)
        allow(schema_double).to receive(:validate).and_return(['error', 'error'])
        allow_any_instance_of(TaxReturn).to receive(:claimed_recovery_rebate_credit).and_return 100
      end

      it "returns an Efile::Response object that responds to #valid? and includes the Schema errors" do
        response = described_class.build(submission)
        expect(response).to be_an_instance_of SubmissionBuilder::Response
        expect(response).not_to be_valid
        expect(response.errors).to eq ['error', 'error']
        expect(response.document).to be_an_instance_of Nokogiri::XML::Document
      end
    end

    context "the XML document contents" do
      it "includes required nodes on the ReturnHeader (filing with Check)" do
        xml = Nokogiri::XML::Document.parse(
          Timecop.freeze(fake_time) { described_class.build(submission).document.to_xml }
        )
        expect(xml.at("ReturnTs").text).to eq submission.created_at.strftime("%FT%T%:z")
        expect(xml.at("TaxYr").text).to eq "2021"
        expect(xml.at("TaxPeriodBeginDt").text).to eq "2021-01-01"
        expect(xml.at("TaxPeriodEndDt").text).to eq "2021-12-31"
        expect(xml.at("SoftwareId").text).to eq "11111111" # placeholder
        expect(xml.at("EFIN").text).to eq "123456"
        expect(xml.at("OriginatorTypeCd").text).to eq "OnlineFiler" # TBD -- change to online filer once we have ONlineFiler EFIN
        expect(xml.at("PINTypeCd").text).to eq "Self-Select On-Line"
        expect(xml.at("JuratDisclosureCd").text).to eq "Online Self Select PIN"
        expect(xml.at("PrimaryPINEnteredByCd").text).to eq "Taxpayer"
        expect(xml.at("SpousePINEnteredByCd").text).to eq "Taxpayer"
        expect(xml.at("PrimaryPriorYearAGIAmt").text).to eq "10000"
        expect(xml.at("SpousePriorYearAGIAmt").text).to eq "0"
        expect(xml.at("PrimarySignaturePIN").text).to eq submission.intake.primary_signature_pin
        expect(xml.at("SpouseSignaturePIN").text).to eq submission.intake.spouse_signature_pin
        expect(xml.at("PrimarySignatureDt").text).to eq submission.intake.primary_signature_pin_at.strftime("%F")
        expect(xml.at("SpouseSignatureDt").text).to eq submission.intake.spouse_signature_pin_at.strftime("%F")
        expect(xml.at('ReturnTypeCd').text).to eq "1040"
        expect(xml.at("PrimarySSN").text).to eq submission.intake.primary_ssn
        expect(xml.at("SpouseSSN").text).to eq submission.intake.spouse_ssn
        expect(xml.at("NameLine1Txt").text).to eq "HUBERT BLAINE<D<& LISA F" # trimmed to 35 characters
        expect(xml.at("PrimaryNameControlTxt").text).to eq "DIWO"
        expect(xml.at("SpouseNameControlTxt").text).to eq "FRAN"
        expect(xml.at("AddressLine1Txt").text).to eq "23627 HAWKINS CREEK CT"
        expect(xml.at("CityNm").text).to eq "KATY"
        expect(xml.at("StateAbbreviationCd").text).to eq "TX"
        expect(xml.at("ZIPCd").text).to eq "77494"
        expect(xml.at("PhoneNum").text).to eq "4155551212"
        expect(xml.at("IPv4AddressTxt").text).to eq "1.1.1.1"
        expect(xml.at("RefundDisbursementGrp RefundDisbursementCd").text).to eq "3"
        expect(xml.at("TrustedCustomerGrp AuthenticationAssuranceLevelCd").text).to eq "AAL1"
        expect(xml.at("TrustedCustomerGrp LastSubmissionRqrOOBCd").text).to eq "0"
        expect(xml.at("AtSubmissionFilingGrp RefundProductElectionInd").text).to eq "false"
        expect(xml.at("AtSubmissionFilingGrp RefundDisbursementGrp RefundProductCIPCd").text).to eq "0"

        expect(xml.at("FilingSecurityInformation AtSubmissionCreationGrp IPAddress IPv4AddressTxt").text).to eq "1.1.1.1"
        expect(xml.at("FilingSecurityInformation AtSubmissionCreationGrp DeviceId").text).to eq "7BA1E530D6503F380F1496A47BEB6F33E40403D1"
        expect(xml.at("FilingSecurityInformation AtSubmissionCreationGrp DeviceTypeCd").text).to eq "1"
        expect(xml.at("FilingSecurityInformation AtSubmissionCreationGrp UserAgentTxt").text).to eq "GeckoFox"
        expect(xml.at("FilingSecurityInformation AtSubmissionCreationGrp BrowserLanguageTxt").text).to eq "en-US"
        expect(xml.at("FilingSecurityInformation AtSubmissionCreationGrp PlatformTxt").text).to eq "MacIntel"
        expect(xml.at("FilingSecurityInformation AtSubmissionCreationGrp TimeZoneOffsetNum").text).to eq "+240"
        expect(xml.at("FilingSecurityInformation AtSubmissionCreationGrp SystemTs").text).to eq "2021-08-02T18:55:41-04:00"

        expect(xml.at("FilingSecurityInformation AtSubmissionFilingGrp IPAddress IPv4AddressTxt").text).to eq "1.1.1.1"
        expect(xml.at("FilingSecurityInformation AtSubmissionFilingGrp DeviceId").text).to eq "7BA1E530D6503F380F1496A47BEB6F33E40403D1"
        expect(xml.at("FilingSecurityInformation AtSubmissionFilingGrp DeviceTypeCd").text).to eq "1"
        expect(xml.at("FilingSecurityInformation AtSubmissionFilingGrp UserAgentTxt").text).to eq "GeckoFox"
        expect(xml.at("FilingSecurityInformation AtSubmissionFilingGrp BrowserLanguageTxt").text).to eq "en-US"
        expect(xml.at("FilingSecurityInformation AtSubmissionFilingGrp PlatformTxt").text).to eq "MacIntel"
        expect(xml.at("FilingSecurityInformation AtSubmissionFilingGrp TimeZoneOffsetNum").text).to eq "+240"
        expect(xml.at("FilingSecurityInformation AtSubmissionFilingGrp SystemTs").text).to eq "2021-08-02T18:55:41-04:00"
        expect(xml.at("FilingSecurityInformation TotalPreparationSubmissionTs").text).to eq((12 * 60).to_s)
        expect(xml.at("FilingSecurityInformation TotActiveTimePrepSubmissionTs").text).to eq("21")
      end

      context "filing as a single filer" do
        let(:filing_status) { "single" }

        it "does not include spouse nodes" do
          xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
          expect(xml.at("SpouseNameControlTxt")).to be_nil
          expect(xml.at("SpouseSSN")).to be_nil
          expect(xml.at("SpouseSignatureDt")).to be_nil
          expect(xml.at("SpouseSignaturePIN")).to be_nil
          expect(xml.at("SpousePriorYearAGIAmt")).to be_nil
        end
      end

      context "filing jointly" do
        let(:filing_status) { "married_filing_jointly" }

        it "returns $0 for the prior year AGI if the spouse did not file" do
          submission.intake.update(spouse_filed_prior_tax_year: "did_not_file")
          xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
          expect(xml.at("SpousePriorYearAGIAmt").text).to eq("0")
        end

        it "returns $1 for the prior year AGI if the non-filer tool was used in 2019" do
          submission.intake.update(spouse_filed_prior_tax_year: "filed_non_filer_joint")
          xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
          expect(xml.at("SpousePriorYearAGIAmt").text).to eq("1")

          submission.intake.update(spouse_filed_prior_tax_year: "filed_non_filer_separate")
          xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
          expect(xml.at("SpousePriorYearAGIAmt").text).to eq("1")
        end

        it "returns the user-entered value for prior year AGI if the spouse filed separately" do
          submission.intake.update(spouse_filed_prior_tax_year: "filed_full_separate", spouse_prior_year_agi_amount: 123)
          xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
          expect(xml.at("SpousePriorYearAGIAmt").text).to eq("123")
        end
      end

      context "PhoneNum" do
        context "when sms phone number is present" do
          before do
            submission.intake.update(sms_phone_number: "+15125551234", phone_number: "+15125551236")
          end

          it "uses intake sms_phone_number" do
            xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
            expect(xml.at("PhoneNum").text).to eq "5125551234"
          end
        end

        context "when sms phone number is not present but phone number is" do
          before do
            submission.intake.update(sms_phone_number: nil, phone_number: "+16125551236")
          end

          it "uses intake phone_number" do
            xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
            expect(xml.at("PhoneNum").text).to eq "6125551236"
          end
        end
      end

      context "CellPhoneNum" do
        context "without an sms_phone_number" do
          before do
            submission.intake.update(sms_phone_number: nil)
          end

          it "excludes the cell phone number from the return" do
            xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
            expect(xml.at("CellPhoneNum")).to be_nil
          end
        end

        context "with an sms_phone_number" do
          before do
            submission.intake.update(sms_phone_number: "+18324651680", sms_phone_number_verified_at: DateTime.current)
          end

          it "excludes the cell phone number from the return" do
            xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
            expect(xml.at("CellPhoneNum").text).to eq "8324651680"
            expect(xml.at("TrustedCustomerGrp OOBSecurityVerificationCd").text).to eq "07"
          end
        end
      end

      context "EmailAddressTxt" do
        context "without an sms_phone_number" do
          before do
            submission.intake.update(email_address: nil)
          end

          it "excludes the email address from the return" do
            xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
            expect(xml.at("EmailAddress")).to be_nil
          end
        end

        context "with an email" do
          before do
            submission.intake.update(email_address: "marla@mango.com", email_address_verified_at: DateTime.current)
          end

          it "excludes the cell phone number from the return" do
            xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
            expect(xml.at("EmailAddressTxt").text).to eq "marla@mango.com"
            expect(xml.at("TrustedCustomerGrp OOBSecurityVerificationCd").text).to eq "03"
          end
        end
      end

      context "filing with direct deposit" do
        before do
          submission.intake.update(refund_payment_method: "direct_deposit")
          allow_any_instance_of(TaxReturn).to receive(:claimed_recovery_rebate_credit).and_return(refund_amount)
        end

        context "with a refund due" do
          let(:refund_amount) { 1 }

          it "includes direct deposit nodes and excludes CheckCd" do
            xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
            expect(xml.at("RoutingTransitNum").text).to eq "123456789"
            expect(xml.at("DepositorAccountNum").text).to eq "87654321"
            expect(xml.at("CheckCd")).to eq nil
            expect(xml.at("RefundDisbursementGrp RefundDisbursementCd").text).to eq "2"
            expect(xml.at("AdditionalFilerInformation AtSubmissionCreationGrp RoutingTransitNum").text).to eq "123456789"
            expect(xml.at("AdditionalFilerInformation AtSubmissionCreationGrp DepositorAccountNum").text).to eq "87654321"
            expect(xml.at("AdditionalFilerInformation AtSubmissionCreationGrp BankAccountDataCapturedTs").text).not_to be_nil
          end
        end

        context "without a refund due" do
          let(:refund_amount) { 0 }

          it "includes direct deposit info and sets RefundDisbursementCd to 0" do
            xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
            expect(xml.at("RoutingTransitNum").text).to eq "123456789"
            expect(xml.at("DepositorAccountNum").text).to eq "87654321"
            expect(xml.at("CheckCd")).to eq nil
            expect(xml.at("RefundDisbursementGrp RefundDisbursementCd").text).to eq "0"
            expect(xml.at("AdditionalFilerInformation AtSubmissionCreationGrp RoutingTransitNum").text).to eq "123456789"
            expect(xml.at("AdditionalFilerInformation AtSubmissionCreationGrp DepositorAccountNum").text).to eq "87654321"
            expect(xml.at("AdditionalFilerInformation AtSubmissionCreationGrp BankAccountDataCapturedTs").text).not_to be_nil
          end
        end
      end
    end

    context "filing requesting a check payment" do
      before do
        submission.intake.update(refund_payment_method: "check")
        allow_any_instance_of(TaxReturn).to receive(:claimed_recovery_rebate_credit).and_return refund_amount
      end

      context "with a refund due" do
        let(:refund_amount) { 1 }

        it "includes CheckCd and exclude direct deposit nodes" do
          xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
          expect(xml.at("RoutingTransitNum")).to be_nil
          expect(xml.at("DepositorAccountNum")).to be_nil
          expect(xml.at("CheckCd").text).to eq "Check"
          expect(xml.at("RefundDisbursementGrp RefundDisbursementCd").text).to eq "3"
        end
      end

      context "with no refund due" do
        let(:refund_amount) { 0 }

        it "includes CheckCd and exclude direct deposit nodes and sets RefundDisbursementCd to 0" do
          xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)

          expect(xml.at("RoutingTransitNum")).to be_nil
          expect(xml.at("DepositorAccountNum")).to be_nil
          expect(xml.at("CheckCd").text).to eq "Check"
          expect(xml.at("RefundDisbursementGrp RefundDisbursementCd").text).to eq "0"
        end
      end

      context "Prior Year Tax Info" do
        let(:refund_amount) { 5 }

        context "with prior year Signature PINs provided" do
          before do
            submission.intake.update(primary_prior_year_signature_pin: "12345", spouse_prior_year_signature_pin: "54321")
          end

          it "in SelfSelectPINGrp, sends PINs and does not send AGIs" do
            xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
            expect(xml.at("SelfSelectPINGrp PrimaryPriorYearAGIAmt")).to be_nil
            expect(xml.at("SelfSelectPINGrp SpousePriorYearAGIAmt")).to be_nil
            expect(xml.at("SelfSelectPINGrp PrimaryPriorYearPIN").text).to eq "12345"
            expect(xml.at("SelfSelectPINGrp SpousePriorYearPIN").text).to eq "54321"
          end
        end

        context "without signature PINs provided" do
          it "in SelfSelectPINGrp, does not send AGI and sends PINs" do
            xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
            expect(xml.at("SelfSelectPINGrp PrimaryPriorYearAGIAmt").text).to eq "10000"
            expect(xml.at("SelfSelectPINGrp SpousePriorYearAGIAmt").text).to eq "0"
            expect(xml.at("SelfSelectPINGrp PrimaryPriorYearPIN")).to be_nil
            expect(xml.at("SelfSelectPINGrp SpousePriorYearPIN")).to be_nil
          end
        end
      end
    end

    context "when re-submitting" do
      let(:previous_submission) { create(:efile_submission, :transmitted, submission_bundle: { filename: "sensible-filename.zip", io: StringIO.new("i am a zip file") }, created_at: DateTime.new(2021, 8, 1, 12, 0)) }

      before do
        create(:efile_submission_transition, :preparing, efile_submission: submission, metadata: {previous_submission_id: previous_submission.id})
      end

      it "adds original submission metadata to the header" do
        expect(submission.previously_transmitted_submission).to eq(previous_submission)
        response = described_class.build(submission)
        xml = Nokogiri::XML::Document.parse(response.document.to_xml)
        expect(xml.at("FederalOriginalSubmissionId").text).to eq previous_submission.irs_submission_id
        expect(xml.at("FederalOriginalSubmissionIdDt").text).to eq "2021-08-01"
      end
    end

    context "efile security information" do
      context "UserAgentTxt" do
        context "when the user agent is over the length limit in the schema" do
          before do
            submission.client.efile_security_informations.first.update(
              user_agent: "Mozilla/5.0 (Linux; Android 10; SAMSUNG SM-S205DL) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/12.1 Chrome/79.0.3945.136 Mobile Safari/537.36",
              browser_language: "es-419",
              platform: "Linux armv8l-more"
            )
            submission.client.efile_security_informations.last.update(
              user_agent: "Mozilla/5.0 (Linux; Android 10; SAMSUNG SM-S205DL) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/12.1 Chrome/79.0.3945.136 Mobile Safari/537.36",
              browser_language: "es-419",
              platform: "Linux armv8l-more"
            )
          end

          it "trims long user agent text down to 150 characters, the max acceptable by the schema" do
            expect(submission.client.efile_security_informations.first.user_agent.length).to eq 151
            expect(submission.client.efile_security_informations.last.user_agent.length).to eq 151
            expect(submission.client.efile_security_informations.first.browser_language.length).to eq 6
            expect(submission.client.efile_security_informations.last.browser_language.length).to eq 6
            expect(submission.client.efile_security_informations.last.platform.length).to eq 17
            expect(submission.client.efile_security_informations.last.platform.length).to eq 17

            response = described_class.build(submission)
            xml = Nokogiri::XML::Document.parse(response.document.to_xml)
            expect(xml.at("FilingSecurityInformation AtSubmissionFilingGrp UserAgentTxt").text.length).to eq 150
            expect(xml.at("FilingSecurityInformation AtSubmissionCreationGrp UserAgentTxt").text.length).to eq 150
            expect(xml.at("FilingSecurityInformation AtSubmissionFilingGrp BrowserLanguageTxt").text.length).to eq 5
            expect(xml.at("FilingSecurityInformation AtSubmissionCreationGrp BrowserLanguageTxt").text.length).to eq 5
            expect(xml.at("FilingSecurityInformation AtSubmissionFilingGrp PlatformTxt").text.length).to eq 15
            expect(xml.at("FilingSecurityInformation AtSubmissionCreationGrp PlatformTxt").text.length).to eq 15
          end
        end

        context "when the user agent text contains multiple adjacent spaces" do
          before do
            submission.client.efile_security_informations.update_all(
              user_agent: "IceFerret/262.10  SpaceySpace",
            )
          end

          it "squishes multiple spaces into a single space so the schema will accept it" do
            response = described_class.build(submission)
            expect(response).to be_valid

            xml = Nokogiri::XML::Document.parse(response.document.to_xml)
            expect(xml.at("FilingSecurityInformation AtSubmissionFilingGrp UserAgentTxt").text).to eq "IceFerret/262.10 SpaceySpace"
            expect(xml.at("FilingSecurityInformation AtSubmissionCreationGrp UserAgentTxt").text).to eq "IceFerret/262.10 SpaceySpace"
          end
        end
      end

      context "TimeZoneOffsetNum" do
        context "when the timezone offset has less than 3 digits" do
          before do
            submission.client.efile_security_informations.where(efile_submission_id: nil).first.update(
              timezone_offset: '-60',
            )
            submission.client.efile_security_informations.where.not(efile_submission_id: nil).first.update(
              timezone_offset: '+60',
            )
          end

          it "pads the offset to contain 3 digits" do
            response = described_class.build(submission)
            xml = Nokogiri::XML::Document.parse(response.document.to_xml)

            expect(xml.at("FilingSecurityInformation AtSubmissionCreationGrp TimeZoneOffsetNum").text).to eq "-060"
            expect(xml.at("FilingSecurityInformation AtSubmissionFilingGrp TimeZoneOffsetNum").text).to eq "+060"
          end
        end
      end
    end

    context "spouse name control" do
      context "when use_primary_name_for_name_control is true" do
        before do
          submission.intake.update(use_primary_name_for_name_control: true)
        end

        it "uses the primary last name to create the name control" do
          response = described_class.build(submission)
          xml = Nokogiri::XML::Document.parse(response.document.to_xml)
          expect(xml.at("SpouseNameControlTxt").text).to eq "DIWO"
        end
      end
    end

    context "when submission is for a 2020 tax return" do
      before do
        submission.tax_return.update(year: 2020)
      end

      context "when testing for schema validity" do
        around do |example|
          ENV["TEST_SCHEMA_VALIDITY_ONLY"] = 'true'
          example.run
          ENV.delete("TEST_SCHEMA_VALIDITY_ONLY")
        end

        it "conforms to the eFileAttachments schema 2020v5.1" do
          instance = described_class.new(submission)
          expect(instance.schema_version).to eq "2020v5.1"

          expect(described_class.build(submission)).to be_valid
        end
      end

      context "when actually trying to build the data" do
        it "raises an error because we dont have proper data to create an accurate return" do
          expect { described_class.build(submission) }.to raise_error(RuntimeError, "primary_prior_year_agi only works for current tax year")
        end
      end
    end

    context "when submission is for a 2021 tax return" do
      before do
        submission.tax_return.update(year: 2021)
      end

      it "conforms to the eFileAttachments schema 2021v5.2" do
        instance = described_class.new(submission)
        expect(instance.schema_version).to eq "2021v5.2"

        expect(described_class.build(submission)).to be_valid
      end
    end
  end
end
