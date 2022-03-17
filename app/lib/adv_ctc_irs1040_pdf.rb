class AdvCtcIrs1040Pdf
  include PdfHelper

  def source_pdf_name
    "TY2020Form1040"
  end

  def initialize(submission)
    @submission = submission
    @tax_return = submission.tax_return
    @intake = submission.intake
    @qualifying_dependents = submission.tax_return.qualifying_dependents
    @address = @submission.address
  end

  def hash_for_pdf
    answers = {
        FilingStatus: @tax_return.filing_status_code,
        PrimaryFirstNm: @intake.primary_first_name,
        PrimaryLastNm: @intake.primary_last_name,
        PrimarySSN: pdf_mask(@intake.primary_ssn, 4),
        AddressLine1Txt: @address&.street_address,
        CityNm: @address&.city,
        StateAbbreviationCd: @address&.state,
        ZIPCd: @address&.zip_code,
        VirtualCurAcquiredDurTYInd: false,
        TaxableInterestAmt2b: 1,
        TotalIncomeAmt9: 1,
        AdjustedGrossIncomeAmt11: 1,
        TotalItemizedOrStandardDedAmt12: @tax_return.standard_deduction,
        TaxableIncomeAmt15: 0,
        RecoveryRebateCreditAmt30: @tax_return.claimed_recovery_rebate_credit,
        RefundableCreditsAmt32: @tax_return.claimed_recovery_rebate_credit,
        TotalPaymentsAmt33: @tax_return.claimed_recovery_rebate_credit,
        OverpaidAmt34: @tax_return.claimed_recovery_rebate_credit,
        RefundAmt35: @tax_return.claimed_recovery_rebate_credit,
        PrimarySignature: @intake.primary_full_name,
        PrimarySignatureDate: @intake.primary_signature_pin_at&.strftime("%m/%d/%y"),
        PrimaryIPPIN: @intake.primary_ip_pin,
        PhoneNumber:  @intake.formatted_phone_number || @intake.formatted_sms_phone_number,
        EmailAddress: @intake.email_address
    }
    answers.merge!(bank_account_info) unless @intake.refund_payment_method_check?
    answers.merge!(spouse_info) if @tax_return.filing_jointly?
    answers.merge!(dependents_info) if @qualifying_dependents.count.nonzero?
    answers
  end

  def bank_account_info
    return {} unless @intake.bank_account.present?

    {
        RoutingTransitNum35b: pdf_mask(@intake.bank_account.routing_number, 4),
        DepositorAccountNum35d: pdf_mask(@intake.bank_account.account_number, 4),
        BankAccountTypeCd: @intake.bank_account.account_type.titleize
    }
  end

  def spouse_info
    {
        SpouseFirstNm: @intake.spouse_first_name,
        SpouseLastNm: @intake.spouse_last_name,
        SpouseSSN: pdf_mask(@intake.spouse_ssn, 4),
        SpouseSignature: @intake.spouse_full_name,
        SpouseSignatureDate: @intake.spouse_signature_pin_at.strftime("%m/%d/%y"),
        SpouseIPPIN: @intake.spouse_ip_pin,
    }
  end

  # TODO: The tax form only allows for 4 dependents. In the case where we have more than 4 dependents, we
  # really ought to attach a second page with dependent information.
  def dependents_info
    answers = {}
    @qualifying_dependents.first(4).each_with_index do |dependent, index|
      answers["DependentLegalNm[#{index}]"] = dependent.full_name
      answers["DependentRelationship[#{index}]"] = dependent.relationship
      answers["DependentSSN[#{index}]"] = pdf_mask(dependent.ssn, 4)
      answers["DependentCTCInd[#{index}]"] = dependent.eligible_for_child_tax_credit?(@tax_return.year) ? 1 : 0
    end
    answers
  end
end