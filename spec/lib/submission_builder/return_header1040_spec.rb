require "rails_helper"

describe SubmissionBuilder::ReturnHeader1040 do
  describe ".build" do
    before do
      allow(EnvironmentCredentials).to receive(:dig).with(:irs, :efin).and_return "123456"
      submission.intake.update(
        primary_first_name: "Hubert Blaine ",
        primary_last_name: "Wolfeschlegelsteinhausenbergerdorff ",
        spouse_first_name: "Lisa",
        spouse_last_name: "Frank"
      )
    end

    let(:submission) { create :efile_submission, :ctc, filing_status: filing_status, tax_year: 2020 }
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
        response = SubmissionBuilder::ReturnHeader1040.build(submission)
        expect(response).to be_an_instance_of SubmissionBuilder::Response
        expect(response).to be_valid
        expect(response.errors).to eq []
        expect(response.document).to be_an_instance_of Nokogiri::XML::Builder
      end
    end

    context "when the XML is not valid against the schema" do
      let(:file_double) { double }
      let(:schema_double) { double }
      before do
        allow(File).to receive(:open).and_return(file_double)
        allow(Nokogiri::XML).to receive(:Schema).with(file_double).and_return(schema_double)
        allow(schema_double).to receive(:validate).and_return(['error', 'error'])
      end

      it "returns an Efile::Response object that responds to #valid? and includes the Schema errors" do
        response = SubmissionBuilder::ReturnHeader1040.build(submission)
        expect(response).to be_an_instance_of SubmissionBuilder::Response
        expect(response).not_to be_valid
        expect(response.errors).to eq ['error', 'error']
        expect(response.document).to be_an_instance_of Nokogiri::XML::Builder
      end
    end

    context "the XML document contents" do
      it "includes required nodes on the ReturnHeader" do
        xml = Nokogiri::XML::Document.parse(SubmissionBuilder::ReturnHeader1040.build(submission).document.to_xml)
        expect(xml.at("ReturnTs").text).to eq submission.created_at.strftime("%FT%T%:z")
        expect(xml.at("TaxYr").text).to eq "2020"
        expect(xml.at("TaxPeriodBeginDt").text).to eq "2020-01-01"
        expect(xml.at("TaxPeriodEndDt").text).to eq "2020-12-31"
        expect(xml.at("SoftwareId").text).to eq "11111111" # placeholder
        expect(xml.at("EFIN").text).to eq "123456"
        expect(xml.at("OriginatorTypeCd").text).to eq "OnlineFiler"
        expect(xml.at("PINTypeCd").text).to eq "Self-Select On-Line"
        expect(xml.at("JuratDisclosureCd").text).to eq "Online Self Select PIN"
        expect(xml.at("PrimaryPINEnteredByCd").text).to eq "Taxpayer"
        expect(xml.at("PrimarySignaturePIN").text).to eq submission.intake.primary_signature_pin
        expect(xml.at("SpouseSignaturePIN").text).to eq submission.intake.spouse_signature_pin
        expect(xml.at("PrimarySignatureDt").text).to eq submission.intake.primary_signature_pin_at.strftime("%F")
        expect(xml.at("SpouseSignatureDt").text).to eq submission.intake.spouse_signature_pin_at.strftime("%F")
        expect(xml.at('ReturnTypeCd').text).to eq "1040"
        expect(xml.at("PrimarySSN").text).to eq submission.intake.primary_ssn
        expect(xml.at("SpouseSSN").text).to eq submission.intake.spouse_ssn
        expect(xml.at("NameLine1Txt").text).to eq "Hubert Blaine Wolfeschlegelsteinhau" # trimmed to 35 characters
        expect(xml.at("PrimaryNameControlTxt").text).to eq "HUBE"
        expect(xml.at("SpouseNameControlTxt").text).to eq "LISA"
        expect(xml.at("AddressLine1Txt").text).to eq "23627 HAWKINS CREEK CT"
        expect(xml.at("CityNm").text).to eq "KATY"
        expect(xml.at("StateAbbreviationCd").text).to eq "TX"
        expect(xml.at("ZIPCd").text).to eq "77494"
        expect(xml.at("PhoneNum").text).to eq "4155551212"
        expect(xml.at("IPv4AddressTxt").text).to eq "192.168.2.1"
      end

      context "filing as a single filer" do
        let(:filing_status) { "single" }

        it "does not include spouse nodes" do
          xml = Nokogiri::XML::Document.parse(SubmissionBuilder::ReturnHeader1040.build(submission).document.to_xml)
          expect(xml.at("SpouseNameControlTxt")).to be_nil
          expect(xml.at("SpouseSSN")).to be_nil
          expect(xml.at("SpouseSignatureDt")).to be_nil
          expect(xml.at("SpouseSignaturePIN")).to be_nil
        end
      end

      context "CellPhoneNum" do
        context "without an sms_phone_number" do
          before do
            submission.intake.update(sms_phone_number: nil)
          end

          it "excludes the cell phone number from the return" do
            xml = Nokogiri::XML::Document.parse(SubmissionBuilder::ReturnHeader1040.build(submission).document.to_xml)
            expect(xml.at("CellPhoneNum")).to be_nil
          end
        end

        context "with an sms_phone_number" do
          before do
            submission.intake.update(sms_phone_number: "+18324651680")
          end

          it "excludes the cell phone number from the return" do
            xml = Nokogiri::XML::Document.parse(SubmissionBuilder::ReturnHeader1040.build(submission).document.to_xml)
            expect(xml.at("CellPhoneNum").text).to eq "8324651680"
          end
        end
      end

      context "filing with direct deposit" do
        before do
          submission.intake.update(refund_payment_method: "direct_deposit")
        end

        it "includes direct deposit nodes and excludes CheckCd" do
          xml = Nokogiri::XML::Document.parse(SubmissionBuilder::ReturnHeader1040.build(submission).document.to_xml)
          expect(xml.at("RoutingTransitNum").text).to eq "12345678"
          expect(xml.at("DepositorAccountNum").text).to eq "87654321"
          expect(xml.at("CheckCd")).to be_nil
        end
      end

      context "filing requesting a check payment" do
        before do
          submission.intake.update(refund_payment_method: "check")
        end

        it "includes CheckCd and exclude direct deposit nodes" do
          xml = Nokogiri::XML::Document.parse(SubmissionBuilder::ReturnHeader1040.build(submission).document.to_xml)

          expect(xml.at("RoutingTransitNum")).to be_nil
          expect(xml.at("DepositorAccountNum")).to be_nil
          expect(xml.at("CheckCd").text).to eq "Check"
        end
      end

      it "conforms to the eFileAttachments schema" do
        expect(SubmissionBuilder::ReturnHeader1040.build(submission)).to be_valid
      end
    end
  end
end