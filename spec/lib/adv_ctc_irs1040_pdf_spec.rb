require "rails_helper"

RSpec.describe AdvCtcIrs1040Pdf do
  include PdfSpecHelper

  let(:pdf) { described_class.new(submission) }
  # Locked to 2020 because the resulting PDF matches 2020 revenue procedure needs.
  let(:submission) { create :efile_submission, :ctc, tax_year: 2020 }

  describe "#output_file" do
    context "with an empty submission record" do

      # "clear out" submission so we can see the empty state of the PDF
      before do
        submission.intake.update(email_address: nil, phone_number: nil, sms_phone_number: nil, primary_first_name: "", primary_last_name: "", primary_ssn: "", claim_owed_stimulus_money: "no" )
        submission.address.destroy!
        submission.intake.bank_account.destroy!
        submission.intake.dependents.destroy_all
        submission.tax_return.update(filing_status: nil)
        submission.reload
      end

      it "returns a pdf with default fields and values" do
        output_file = pdf.output_file
        result = non_preparer_fields(output_file.path)
        expect(result).to match({
                                    "AdditionalChildTaxCreditAmt28" => nil,
                                    "AdditionalTaxAmt17" => nil,
                                    "AddressLine1Txt" => "",
                                    "AdjustedGrossIncomeAmt11" => "1",
                                    "AppliedToEsTaxAmt36" => nil,
                                    "BankAccountTypeCd" => nil,
                                    "CDCODCAmt19" => nil,
                                    "CapitalGainLossAmt7" => nil,
                                    "CharitableContributionAmt10b" => nil,
                                    "CityNm" => "",
                                    "DependentCTCInd[0]" => nil,
                                    "DependentCTCInd[1]" => nil,
                                    "DependentCTCInd[2]" => nil,
                                    "DependentCTCInd[3]" => nil,
                                    "DependentLegalNm[0]" => nil,
                                    "DependentLegalNm[1]" => nil,
                                    "DependentLegalNm[2]" => nil,
                                    "DependentLegalNm[3]" => nil,
                                    "DependentOTCInd[0]" => nil,
                                    "DependentOTCInd[1]" => nil,
                                    "DependentOTCInd[2]" => nil,
                                    "DependentOTCInd[3]" => nil,
                                    "DependentRelationship[0]" => nil,
                                    "DependentRelationship[1]" => nil,
                                    "DependentRelationship[2]" => nil,
                                    "DependentRelationship[3]" => nil,
                                    "DependentSSN[0]" => nil,
                                    "DependentSSN[1]" => nil,
                                    "DependentSSN[2]" => nil,
                                    "DependentSSN[3]" => nil,
                                    "DepositorAccountNum35d" => nil,
                                    "EarnedIncomeCreditAmt27" => nil,
                                    "EmailAddress" => "",
                                    "EsPenaltyAmt38" => nil,
                                    "EstimatedTaxPaymentsAmt26" => nil,
                                    "FilingStatus" => "",
                                    "Form1099WithheldTaxAmt25b" => nil,
                                    "Form8814Ind7" => nil,
                                    "FormW2WithheldTaxAmt25a" => nil,
                                    "Has4972Ind16_2" => nil,
                                    "Has8814Ind16_1" => nil,
                                    "HasOtherFormInd16_3" => nil,
                                    "IRADistributionsAmt4a" => nil,
                                    "MustItemizeInd" => nil,
                                    "OrdinaryDividendsAmt3b" => nil,
                                    "OtherFormName16_3" => nil,
                                    "OverpaidAmt34" => "0",
                                    "OwedAmt37" => nil,
                                    "PensionsAnnuitiesAmt5a" => nil,
                                    "PhoneNumber" => "",
                                    "Primary65OrOlderInd" => nil,
                                    "PrimaryBlindInd" => nil,
                                    "PrimaryClaimAsDependentInd" => nil,
                                    "PrimaryFirstNm" => "",
                                    "PrimaryIPPIN" => "",
                                    "PrimaryLastNm" => "",
                                    "PrimarySSN" => "",
                                    "PrimarySignature" => "",
                                    "PrimaryOccupation" => nil,
                                    "PrimarySignatureDate" => "",
                                    "RecoveryRebateCreditAmt30" => "0",
                                    "VirtualCurAcquiredDurTYInd" => "false",
                                    "QualifiedBusinessIncomeDedAmt13" => nil,
                                    "QualifiedDividendsAmt3a" => nil,
                                    "QualifyingPersonName" => nil,
                                    "RefundAmt35" => "0",
                                    "RefundableAmerOppCreditAmt29" => nil,
                                    "RefundableCreditsAmt32" => "0",
                                    "RoutingTransitNum35b" => nil,
                                    "SocSecBenAmt6a" => nil,
                                    "Spouse65OrOlderInd" => nil,
                                    "SpouseBlindInd" => nil,
                                    "SpouseClaimAsDependentInd" => nil,
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
                                    "TaxableIncomeAmt15" => "0",
                                    "TaxableInterestAmt2b" => "1",
                                    "TaxableSocSecAmt6b" => nil,
                                    "TotalAdditionalIncomeAmt8" => nil,
                                    "TotalAdjustmentsAmt10a" => nil,
                                    "TotalAdjustmentsToIncomeAmt10c" => nil,
                                    "TotalCreditsAmt21" => nil,
                                    "TotalDeductionsAmt14" => nil,
                                    "TotalIncomeAmt9" => "1",
                                    "TotalItemizedOrStandardDedAmt12" => "",
                                    "TotalNonrefundableCreditsAmt20" => nil,
                                    "TotalOtherPaymentsRfdblCrAmt31" => nil,
                                    "TotalOtherTaxesAmt23" => nil,
                                    "TotalPaymentsAmt33" => "0",
                                    "TotalTaxAmt24" => nil,
                                    "TotalTaxBeforeCrAndOthTaxesAmt18" => nil,
                                    "TotalTaxablePensionsAmt5b" => nil,
                                    "WagesSalariesAndTipsAmt1" => nil,
                                    "WithholdingTaxAmt25d" => nil,
                                    "ZIPCd" => "",
       })
      end
    end

    context "with a filled out submission record" do
      before do
        submission.intake.update(primary_ip_pin: "12345", primary_signature_pin_at: Date.new(2020, 1, 1))
        submission.reload

        @claimed_rrc = "1000"
        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:claimed_recovery_rebate_credit).and_return @claimed_rrc
      end

      it "returns a filled out pdf" do
        output_file = pdf.output_file
        result = non_preparer_fields(output_file.path)
        expect(result).to match(hash_including(
          "FilingStatus" => "1",
          "PrimaryFirstNm" => submission.intake.primary_first_name,
          "PrimaryLastNm" => submission.intake.primary_last_name,
          "PrimarySSN" => "XXXXX#{submission.intake.primary_ssn.last(4)}",
          "AddressLine1Txt" => "23627 HAWKINS CREEK CT",
          "CityNm" => "KATY",
          "StateAbbreviationCd" => "TX",
          "ZIPCd" => "77494",
          "VirtualCurAcquiredDurTYInd" => "false",
          "TaxableInterestAmt2b" => "1",
          "TotalIncomeAmt9" => "1",
          "AdjustedGrossIncomeAmt11" => "1",
          "TotalItemizedOrStandardDedAmt12" => "12400",
          "TaxableIncomeAmt15" => "0",
          "RecoveryRebateCreditAmt30" => @claimed_rrc.to_s,
          "RefundableCreditsAmt32" => @claimed_rrc.to_s,
          "TotalPaymentsAmt33" => @claimed_rrc.to_s,
          "OverpaidAmt34" => @claimed_rrc.to_s,
          "RefundAmt35" => @claimed_rrc.to_s,
          "PrimarySignature" => "#{submission.intake.primary_first_name} #{submission.intake.primary_last_name}",
          "PrimarySignatureDate" => "01/01/20",
          "PrimaryIPPIN" => "12345",
          "PhoneNumber" => "(415) 555-1212",
          "EmailAddress" => submission.intake.email_address,
          "RoutingTransitNum35b" => "XXXXX6789",
          "DepositorAccountNum35d" => "XXXX4321",
          "BankAccountTypeCd" => "Checking"
       ))
      end
    end

    context "when status is married filing jointly" do
      before do
        submission.intake.update(
          spouse_first_name: "Randall",
          spouse_last_name: "Rouse",
          spouse_signature_pin_at: Date.new(2020, 1, 5),
          spouse_ip_pin: "123456",
          spouse_ssn: "123456789"
        )
        submission.tax_return.update(filing_status: "married_filing_jointly")
        submission.reload
      end

      it "includes spouse information and changes standard deduction and filing status" do
        output_file = pdf.output_file
        result = non_preparer_fields(output_file.path)
        expect(result).to match(hash_including(
          "SpouseFirstNm" => "Randall",
          "SpouseLastNm" => "Rouse",
          "SpouseSSN" => "XXXXX6789",
          "SpouseSignature" => "Randall Rouse",
          "SpouseSignatureDate" => "01/05/20",
          "SpouseIPPIN" => "123456"
        ))
      end
    end

    context "with filled out qualifying dependents" do
      let(:daughter) do
        create :qualifying_child,
               first_name: "Danielle",
               last_name: "Dob",
               ssn: "123456789",
               relationship: "daughter",
               birth_date: Date.new(2015, 2, 25)
      end
      let(:son) do
        create :qualifying_child,
               first_name: "Daniel",
               last_name: "Dob",
               ssn: "123456788",
               relationship: "son",
               birth_date: Date.new(2015, 2, 26)
      end
      let(:mother) do
        create :qualifying_relative,
               first_name: "Mother",
               last_name: "Dob",
               ssn: "123455788",
               relationship: "parent",
               birth_date: Date.new(1965, 2, 26)
      end
      before do
        allow_any_instance_of(TaxReturn).to receive(:qualifying_dependents).and_return([daughter, son, mother])
      end

      it "returns correct values for dependents" do
        output_file = pdf.output_file
        result = non_preparer_fields(output_file.path)
        expect(result).to match(hash_including(
          "DependentLegalNm[0]" => "Danielle Dob",
          "DependentRelationship[0]" => "daughter",
          "DependentSSN[0]" => "XXXXX6789",
          "DependentCTCInd[0]" => "1", # checked
          "DependentLegalNm[1]" => "Daniel Dob",
          "DependentRelationship[1]" => "son",
          "DependentSSN[1]" => "XXXXX6788",
          "DependentCTCInd[1]" => "1", # checked
          "DependentLegalNm[2]" => "Mother Dob",
          "DependentRelationship[2]" => "parent",
          "DependentSSN[2]" => "XXXXX5788",
          "DependentCTCInd[2]" => "0", # unchecked
        ))
      end
    end
  end
end
