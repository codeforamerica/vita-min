module PdfFiller
  class Irs1040Pdf
    include PdfHelper

    def source_pdf_name
      "f1040-TY2021"
    end

    def initialize(submission)
      # For some PDF fields, use values from the database b/c the XML values are truncated or missing.
      @intake = submission.intake
      @address = submission.verified_address || @intake.address

      # Most PDF fields are grabbed right off the XML
      @xml_document = SubmissionBuilder::Ty2021::Return1040.new(submission).document
    end

    def hash_for_pdf
      answers = {
        FilingStatus: @xml_document.at("IndividualReturnFilingStatusCd")&.text,
        PrimaryFirstNm: @intake.primary.middle_initial.present? ? "#{@intake.primary.first_name} #{@intake.primary.middle_initial}" : @intake.primary.first_name,
        PrimaryLastNm: @intake.primary.last_name,
        PrimarySSN: @xml_document.at("PrimarySSN")&.text,
        AddressLine1Txt: [@address.urbanization, @address.street_address, @address.street_address2].compact.join(" "),
        CityNm: @address.city,
        StateAbbreviationCd: @address.state,
        ZipCd: @address.zip_code,
        VirtualCurAcquiredDurTYInd: @xml_document.at("VirtualCurAcquiredDurTYInd")&.text,
        PrimaryBlindInd: xml_value_to_bool(@xml_document.at("PrimaryBlindInd"), "CheckboxType") ? "1" : "Off",
        TotalItemizedOrStandardDedAmt12a: @xml_document.at("TotalItemizedOrStandardDedAmt")&.text,
        TotalAdjustmentsToIncomeAmt12c: @xml_document.at("TotDedCharitableContriAmt")&.text,
        TotalDeductionsAmt14: @xml_document.at("TotalDeductionsAmt")&.text,
        TaxableIncomeAmt15: @xml_document.at("TaxableIncomeAmt")&.text,
        AdditionalChildTaxCreditAmt28: @xml_document.at("RefundableCTCOrACTCAmt")&.text,
        RecoveryRebateCreditAmt30: @xml_document.at("RecoveryRebateCreditAmt")&.text,
        RefundableCreditsAmt32: @xml_document.at("RefundableCreditsAmt")&.text,
        TotalPaymentsAmt33: @xml_document.at("TotalPaymentsAmt")&.text,
        OverpaidAmt34: @xml_document.at("OverpaidAmt")&.text,
        RefundAmt35: @xml_document.at("RefundAmt")&.text,
        Primary65OrOlderInd: xml_value_to_bool(@xml_document.at("Primary65OrOlderInd"), "CheckboxType") ? "1" : "Off",
        PrimaryIPPIN: @xml_document.at("IdentityProtectionPIN")&.text,
        PhoneNumber: PhoneParser.formatted_phone_number(@xml_document.at("PhoneNum")&.text),
        EmailAddress: @xml_document.at("EmailAddressTxt")&.text
      }
      answers.merge!(spouse_info) if @xml_document.at("IndividualReturnFilingStatusCd")&.text.to_i == TaxReturn.filing_statuses[:married_filing_jointly]
      dependent_nodes = @xml_document.search("DependentDetail")
      answers.merge!(dependents_info(dependent_nodes)) if dependent_nodes.any?
      answers.merge!(eitc_info)
      answers
    end

    def sensitive_fields_hash_for_pdf
      bank_info
    end

    private

    def eitc_info
      {
        WagesSalariesAndTipsAmt1: @xml_document.at("WagesSalariesAndTipsAmt")&.text,
        TotalIncomeAmt9: @xml_document.at("TotalIncomeAmt")&.text,
        AdjustedGrossIncomeAmt11: @xml_document.at("AdjustedGrossIncomeAmt")&.text,
        FormW2WithheldTaxAmt25a: @xml_document.at("FormW2WithheldTaxAmt")&.text,
        WithholdingTaxAmt25d: @xml_document.at("WithholdingTaxAmt")&.text,
        EarnedIncomeCreditAmt27a: @xml_document.at("EarnedIncomeCreditAmt")&.text,
        QualifiedFosterOrHomelessYouth: xml_value_to_bool(@xml_document.at("UndSpcfdAgeStsfyRqrEICInd"), "CheckboxType") ? "1" : "Off",
      }
    end

    def bank_info
      types_to_string = {
        "1" => "Checking",
        "2" => "Savings"
      }

      {
        RoutingTransitNum35b:  @xml_document.at("RoutingTransitNum")&.text,
        BankAccountTypeCd: types_to_string[@xml_document.at("BankAccountTypeCd")&.text],
        DepositorAccountNum35d: @xml_document.at("DepositorAccountNum")&.text,
      }
    end

    def spouse_info
      {
        Spouse65OrOlderInd: xml_value_to_bool(@xml_document.at("Spouse65OrOlderInd"), "CheckboxType") ? "1" : "Off",
        SpouseFirstNm: @intake.spouse.middle_initial.present? ? "#{@intake.spouse.first_name} #{@intake.spouse.middle_initial}" : @intake.spouse.first_name,
        SpouseLastNm: @intake.spouse.last_name,
        SpouseSSN: @xml_document.at("SpouseSSN")&.text,
        SpouseDateOfDeath: @xml_document.at("SpouseDeathDt")&.text,
        SpouseIPPIN: @xml_document.at("SpouseIdentityProtectionPIN")&.text,
        SpouseBlindInd: xml_value_to_bool(@xml_document.at("SpouseBlindInd"), "CheckboxType") ? "1" : "Off",
      }
    end

    # TODO: The tax form only allows for 4 dependents. In the case where we have more than 4 dependents, we
    # really ought to attach a second page with dependent information.
    def dependents_info(dependent_nodes)
      answers = {}
      dependent_nodes.first(4).each_with_index do |dependent, index|
        answers["DependentLegalNm[#{index}]"] = [dependent.at("DependentFirstNm").text, dependent.at("DependentLastNm").text].join(" ")
        answers["DependentRelationship[#{index}]"] = dependent.at("DependentRelationshipCd").text
        answers["DependentSSN[#{index}]"] = dependent.at("DependentSSN").text
        answers["DependentCTCInd[#{index}]"] = xml_value_to_bool(dependent.at("EligibleForChildTaxCreditInd"), "CheckboxType") ? 1 : 0
      end
      answers
    end
  end
end
