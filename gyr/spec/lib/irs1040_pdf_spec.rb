require "rails_helper"

RSpec.describe Irs1040Pdf do
  include PdfSpecHelper

  let(:pdf) { described_class.new(submission) }
  # Locked to 2021 because the resulting PDF matches 2021 revenue procedure needs.
  let(:tax_year) { 2021 }
  let(:submission) { create :efile_submission, :ctc, tax_year: tax_year }
  let(:filing_status) { '1' }
  let(:optional_xml_fields) { nil }
  let(:fake_xml_document) {
    Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.RootNode do
        xml.IndividualReturnFilingStatusCd filing_status
        xml.PrimarySSN '111223333'
        xml.VirtualCurAcquiredDurTYInd 'true'
        xml.TotalItemizedOrStandardDedAmt '999'
        xml.TotDedCharitableContriAmt '999'
        xml.TotalDeductionsAmt '999'
        xml.TaxableIncomeAmt '100'
        xml.RefundableCTCOrACTCAmt '100'
        xml.RecoveryRebateCreditAmt '200'
        xml.RefundableCreditsAmt '300'
        xml.TotalPaymentsAmt '400'
        xml.OverpaidAmt '500'
        xml.RefundAmt '600'
        xml.IdentityProtectionPIN '12345'
        xml.PhoneNum '4155551212'
        xml.EmailAddressTxt 'example@example.com'
        optional_xml_fields.call(xml) if optional_xml_fields
      end
    end.doc
  }

  before do
    allow_any_instance_of(SubmissionBuilder::Ty2021::Return1040).to receive(:document).and_return fake_xml_document
  end

  describe "#output_file" do
    context "without values" do
      let(:fake_xml_document) {
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.RootNode do
          end
        end.doc
      }

      it "returns defaults" do
        submission.intake.update(email_address: nil, phone_number: nil, sms_phone_number: nil, primary_first_name: "", primary_last_name: "", primary_ssn: "", claim_owed_stimulus_money: "no", zip_code: "", city: "", state: "", street_address: "", street_address2: "")
        submission.verified_address.destroy!
        submission.intake.dependents.destroy_all
        submission.tax_return.update(filing_status: nil)
        submission.reload

        output_file = pdf.output_file
        expect(filled_in_values(output_file.path)).to match({
          "AdditionalChildTaxCreditAmt28" => "",
          "AdditionalTaxAmt17" => nil,
          "AddressLine1Txt" => "",
          "AdjustedGrossIncomeAmt11" => "",
          "AppliedToEsTaxAmt36" => nil,
          "BankAccountTypeCd" => nil,
          "CDCODCAmt19" => nil,
          "CapitalGainLossAmt7" => nil,
          "CharitableContributionAmt12b" => nil,
          "CityNm" => "",
          "DependentCTCInd[0]" => "Off",
          "DependentCTCInd[1]" => "Off",
          "DependentCTCInd[2]" => "Off",
          "DependentCTCInd[3]" => "Off",
          "DependentOTCInd[0]" => "Off",
          "DependentOTCInd[1]" => "Off",
          "DependentOTCInd[2]" => "Off",
          "DependentOTCInd[3]" => "Off",
          "DependentLegalNm[0]" => nil,
          "DependentLegalNm[1]" => nil,
          "DependentLegalNm[2]" => nil,
          "DependentLegalNm[3]" => nil,
          "DependentRelationship[0]" => nil,
          "DependentRelationship[1]" => nil,
          "DependentRelationship[2]" => nil,
          "DependentRelationship[3]" => nil,
          "DependentSSN[0]" => nil,
          "DependentSSN[1]" => nil,
          "DependentSSN[2]" => nil,
          "DependentSSN[3]" => nil,
          "DepositorAccountNum35d" => nil,
          "EarnedIncomeCreditAmt27a" => "",
          "EmailAddress" => "",
          "EsPenaltyAmt38" => nil,
          "EstimatedTaxPaymentsAmt26" => nil,
          "FilingStatus" => "",
          "Form1099WithheldTaxAmt25b" => nil,
          "Form8814Ind7" => "Off",
          "FormW2WithheldTaxAmt25a" => "",
          "Has4972Ind16_2" => "Off",
          "Has8814Ind16_1" => "Off",
          "HasOtherFormInd16_3" => "Off",
          "IRADistributionsAmt4a" => nil,
          "MustItemizeInd" => "Off",
          "NontaxCombatPay27a" => nil,
          "OrdinaryDividendsAmt3b" => nil,
          "OtherFormName16_3" => nil,
          "OverpaidAmt34" => "",
          "OwedAmt37" => nil,
          "PensionsAnnuitiesAmt5a" => nil,
          "PhoneNumber" => "",
          "Primary65OrOlderInd" => "Off",
          "PrimaryBlindInd" => "Off",
          "PrimaryClaimAsDependentInd" => "Off",
          "PrimaryFirstNm" => "",
          "PrimaryIPPIN" => "",
          "PrimaryLastNm" => "",
          "PrimarySSN" => "",
          "PrimarySignature" => nil,
          "PrimaryOccupation" => nil,
          "PrimarySignatureDate" => nil,
          "PriorYrIncome27c" => nil,
          "RecoveryRebateCreditAmt30" => "",
          "VirtualCurAcquiredDurTYInd" => "",
          "QualifiedBusinessIncomeDedAmt13" => nil,
          "QualifiedDividendsAmt3a" => nil,
          "QualifiedFosterOrHomelessYouth" => "Off",
          "QualifyingPersonName" => nil,
          "RefundAmt35" => "",
          "RefundableAmerOppCreditAmt29" => nil,
          "RefundableCreditsAmt32" => "",
          "RoutingTransitNum35b" => nil,
          "SocSecBenAmt6a" => nil,
          "Spouse65OrOlderInd" => "Off",
          "SpouseBlindInd" => "Off",
          "SpouseClaimAsDependentInd" => "Off",
          "SpouseFirstNm" => nil,
          "SpouseIPPIN" => nil,
          "SpouseLastNm" => nil,
          "SpouseOccupation" => nil,
          "SpouseSSN" => nil,
          "SpouseSignature" => nil,
          "SpouseSignatureDate" => nil,
          "StateAbbreviationCd" => "",
          "TaxAmt16" => nil,
          "TaxExemptInterestAmt2a" => nil,
          "TaxLessCreditsAmt22" => nil,
          "TaxWithheldOtherAmt25c" => nil,
          "TaxableIRAAmt4b" => nil,
          "TaxableIncomeAmt15" => "",
          "TaxableInterestAmt2b" => nil,
          "TaxableSocSecAmt6b" => nil,
          "TotalAdditionalIncomeAmt8" => nil,
          "TotalAdjustmentsAmt10" => nil,
          "TotalAdjustmentsToIncomeAmt12c" => "",
          "TotalCreditsAmt21" => nil,
          "TotalDeductionsAmt14" => "",
          "TotalIncomeAmt9" => "",
          "TotalItemizedOrStandardDedAmt12a" => "",
          "TotalNonrefundableCreditsAmt20" => nil,
          "TotalOtherPaymentsRfdblCrAmt31" => nil,
          "TotalOtherTaxesAmt23" => nil,
          "TotalPaymentsAmt33" => "",
          "TotalTaxAmt24" => nil,
          "TotalTaxBeforeCrAndOthTaxesAmt18" => nil,
          "TotalTaxablePensionsAmt5b" => nil,
          "WagesSalariesAndTipsAmt1" => "",
          "WithholdingTaxAmt25d" => "",
          "ZipCd" => "",
        })
      end
    end

    it "renders xml fields" do
      output_file = pdf.output_file
      result = filled_in_values(output_file.path)
      expect(result).to match(hash_including(
        "FilingStatus" => "1",
        "PrimarySSN" => '111223333',
        "VirtualCurAcquiredDurTYInd" => "true",
        "TotalItemizedOrStandardDedAmt12a" => "999",
        "TotalAdjustmentsToIncomeAmt12c" => "999",
        "TotalDeductionsAmt14" => "999",
        "TaxableIncomeAmt15" => "100",
        "RecoveryRebateCreditAmt30" => "200",
        "RefundableCreditsAmt32" => "300",
        "TotalPaymentsAmt33" => "400",
        "OverpaidAmt34" => "500",
        "RefundAmt35" => "600",
        "PrimaryIPPIN" => "12345",
        "PhoneNumber" => "(415) 555-1212",
        "EmailAddress" => "example@example.com",
        "Primary65OrOlderInd" => "Off",
        "PrimaryBlindInd" => "Off",
      ))
    end

    context "with no verified address" do
      before do
        submission.update(verified_address: nil)
        submission.intake.update(street_address2: "UNIT 2", street_address: "850 Mission St")
      end

      it "puts street_address and street_address2 onto the document" do
        output_file = pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to match(hash_including(
          "AddressLine1Txt" => "850 Mission St UNIT 2",
        ))
      end
    end

    context "with an urbanization code within a Puerto Rico address" do
      before do
        submission.verified_address.update!(urbanization: "Urb Picard")
      end

      it "puts the urbanization into the street_address" do
        output_file = pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to match(hash_including(
          "AddressLine1Txt" => "Urb Picard 23627 HAWKINS CREEK CT",
        ))
      end
    end

    it 'renders fields that have to be from the db instead of xml because the xml is truncated or weird' do
      output_file = pdf.output_file
      result = filled_in_values(output_file.path)
      expect(result).to match(hash_including(
        "PrimaryFirstNm" => submission.intake.primary.first_name,
        "PrimaryLastNm" => submission.intake.primary.last_name,
        "AddressLine1Txt" => "23627 HAWKINS CREEK CT",
        "CityNm" => "KATY",
        "StateAbbreviationCd" => "TX",
        "ZipCd" => "77494",
      ))
    end

    context "when primary filer is older than 65" do
      let(:optional_xml_fields) do
        lambda do |xml|
          xml.Primary65OrOlderInd 'X'
        end
      end

      it "returns 1" do
        output_file = pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to match(hash_including("Primary65OrOlderInd" => "1"))
      end
    end

    context "when primary filer is blind" do
      let(:optional_xml_fields) do
        lambda do |xml|
          xml.PrimaryBlindInd 'X'
        end
      end

      it "returns 1" do
        output_file = pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to match(hash_including("PrimaryBlindInd" => "1"))
      end
    end

    context 'when there is no verified address' do
      it 'uses the intake address' do
        submission.update!(verified_address: nil)
        output_file = pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to match(hash_including(
          "AddressLine1Txt" => "972 Mission St",
          "CityNm" => "San Francisco",
          "StateAbbreviationCd" => "CA",
          "ZipCd" => "94103",
        ))
      end
    end

    context "when status is married filing jointly" do
      let(:filing_status) { '2' }
      let(:result) { filled_in_values(pdf.output_file.path) }
      let(:optional_xml_fields) do
        lambda do |xml|
          xml.SpouseSSN "123456789"
          xml.SpouseIdentityProtectionPIN "123456"
        end
      end

      before do
        submission.intake.update(
          spouse_first_name: "Randall",
          spouse_last_name: "Rouse",
        )
      end

      it "includes spouse information from xml" do
        expect(result).to match(hash_including(
          "Spouse65OrOlderInd" => "Off",
          "SpouseSSN" => "123456789",
          "SpouseIPPIN" => "123456",
          "SpouseBlindInd" => "Off",
        ))
      end

      it 'includes spouse name from the db' do
        expect(result).to match(hash_including(
          "SpouseFirstNm" => "Randall",
          "SpouseLastNm" => "Rouse",
        ))
      end

      context "when spouse is older than 65" do
        let(:optional_xml_fields) do
          lambda do |xml|
            xml.SpouseSSN "123456789"
            xml.SpouseIdentityProtectionPIN "123456"
            xml.Spouse65OrOlderInd 'X'
          end
        end

        it "returns 1" do
          output_file = pdf.output_file
          result = filled_in_values(output_file.path)
          expect(result).to match(hash_including("Spouse65OrOlderInd" => "1"))
        end
      end

      context "when spouse is blind" do
        let(:optional_xml_fields) do
          lambda do |xml|
            xml.SpouseSSN "123456789"
            xml.SpouseIdentityProtectionPIN "123456"
            xml.SpouseBlindInd 'X'
          end
        end

        it "returns 1" do
          output_file = pdf.output_file
          result = filled_in_values(output_file.path)
          expect(result).to match(hash_including("SpouseBlindInd" => "1"))
        end
      end
    end

    context "with filled out qualifying dependents" do
      let(:optional_xml_fields) do
        lambda do |xml|
          xml.DependentDetail do
            xml.DependentFirstNm "Danielle"
            xml.DependentLastNm "Dob"
            xml.DependentRelationshipCd "DAUGHTER"
            xml.DependentSSN "123456789"
            xml.EligibleForChildTaxCreditInd "X"
          end
          xml.DependentDetail do
            xml.DependentFirstNm "Daniel"
            xml.DependentLastNm "Dob2"
            xml.DependentRelationshipCd "SON"
            xml.DependentSSN "123456788"
            xml.EligibleForChildTaxCreditInd "X"
          end
          xml.DependentDetail do
            xml.DependentFirstNm "Mother"
            xml.DependentLastNm "Dob3"
            xml.DependentRelationshipCd "PARENT"
            xml.DependentSSN "123455787"
          end
        end
      end

      it "returns correct values for dependents" do
        output_file = pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to match(hash_including(
          "DependentLegalNm[0]" => "Danielle Dob",
          "DependentRelationship[0]" => "DAUGHTER",
          "DependentSSN[0]" => "123456789",
          "DependentCTCInd[0]" => "1", # checked
          "DependentLegalNm[1]" => "Daniel Dob2",
          "DependentRelationship[1]" => "SON",
          "DependentSSN[1]" => "123456788",
          "DependentCTCInd[1]" => "1", # checked
          "DependentLegalNm[2]" => "Mother Dob3",
          "DependentRelationship[2]" => "PARENT",
          "DependentSSN[2]" => "123455787",
          "DependentCTCInd[2]" => "0", # unchecked
        ))
      end
    end

    describe "#sensitive_fields_for_pdf" do
      let(:optional_xml_fields) do
        lambda do |xml|
          xml.RoutingTransitNum '12345'
          xml.BankAccountTypeCd '1'
          xml.DepositorAccountNum '54321'
        end
      end

      it "includes bank account information" do
        expect(described_class.new(submission).sensitive_fields_hash_for_pdf).to eq(
          RoutingTransitNum35b: "12345",
          BankAccountTypeCd: "Checking",
          DepositorAccountNum35d: "54321"
        )
      end
    end

    context "with a client claiming EITC" do
      let(:optional_xml_fields) do
        lambda do |xml|
          xml.WagesSalariesAndTipsAmt "223"
          xml.TotalIncomeAmt "223"
          xml.AdjustedGrossIncomeAmt "223"
          xml.FormW2WithheldTaxAmt "5"
          xml.WithholdingTaxAmt "5"
          xml.EarnedIncomeCreditAmt "34"
          xml.UndSpcfdAgeStsfyRqrEICInd "X"
        end
      end

      it "includes eitc information from xml" do
        output_file = pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to match(hash_including(
          "WagesSalariesAndTipsAmt1" => "223",
          "TotalIncomeAmt9" => "223",
          "AdjustedGrossIncomeAmt11" => "223",
          "FormW2WithheldTaxAmt25a" => "5",
          "WithholdingTaxAmt25d" => "5",
          "EarnedIncomeCreditAmt27a" => "34",
          "QualifiedFosterOrHomelessYouth" => "1",
        ))
      end
    end
  end
end
