class Irs8812Ty2021Pdf
  include PdfHelper

  def source_pdf_name
    "f8812-TY2021"
  end

  def initialize(submission)
    @full_names = [submission.intake.primary_full_name]
    @ssn = submission.intake.primary_ssn
    if submission.tax_return.filing_jointly?
      @full_names << submission.intake.spouse_full_name
    end
    @xml_document = SubmissionBuilder::Ty2021::Documents::Schedule8812.new(submission).document
  end

  def hash_for_pdf
    {
      FullPrimaryName: @full_names.join(', '),
      PrimarySSN: @ssn,
      AdjustedGrossIncomeAmt1: @xml_document.at("AdjustedGrossIncomeAmt")&.text, # 1
      PRExcludedIncomeAmt2a: @xml_document.at("ExcldSect933PuertoRicoIncmAmt")&.text, # 2a
      GrossIncomeExclusionAmt2c: @xml_document.at("GrossIncomeExclusionAmt")&.text, # 2c
      ExclusionsTotalAmt2d: @xml_document.at("AdditionalIncomeAdjAmt")&.text, #2d
      AGIExclusionsTotalAmt3: @xml_document.at("ModifiedAGIAmt")&.text, #3
      NumQCSsn4a: @xml_document.at("QlfyChildUnderAgeSSNCnt")&.text, #4a
      NumQCOverSix4b: @xml_document.at("QlfyChildIncldUnderAgeSSNCnt")&.text, #4b
      NumQCUnderSix4c: @xml_document.at("QlfyChildOverAgeSSNCnt")&.text, #4c
      TotalCtcAmt5: @xml_document.at("MaxCTCAfterLimitAmt")&.text, #5
      NumNonCtcDependents6: @xml_document.at("OtherDependentCnt")&.text, #6
      OtherDependentCreditAmt7: @xml_document.at("OtherDependentCreditAmt")&.text, #7
      TotalCreditAmt8: @xml_document.at("InitialCTCODCAmt")&.text, #8
      FilingStatusIncomeLimit9: @xml_document.at("FilingStatusThresholdCd")&.text, #9
      Line10: @xml_document.at("ExcessAdjGrossIncomeAmt")&.text, #10
      Line11: @xml_document.at("ModifiedAGIPhaseOutAmt")&.text, #11
      TotalCreditAmt12: @xml_document.at("CTCODCAfterAGILimitAmt")&.text, #12 (=8)
      USHomeInd13a: xml_check_to_bool(@xml_document.at("MainHomeInUSOverHalfYrInd")) ? "1" : "Off", #13a
      PRResidentInd13b: xml_check_to_bool(@xml_document.at("BonaFidePRResidentInd")) ? "1" : "Off", #13b
      OtherDependentCreditAmt14a: @xml_document.at("ODCAfterAGILimitAmt")&.text, #14a (=7)
      TotalCtcAmt14b: @xml_document.at("CTCAfterAGILimitAmt")&.text, #14b (=5)
      Line14c: @xml_document.at("RCTCTaxLiabiltyLimitAmt")&.text, #14c
      Line14d: @xml_document.at("ODCAfterTaxLiabilityLimitAmt")&.text, #14d
      TotalCtcAmt14e: @xml_document.at("CTCODCAfterTaxLiabilityLmtAmt")&.text, #14e (=5)
      AdvCtcReceived14f: @xml_document.at("AggregateAdvncCTCAmt")&.text, #14f
      CtcOwed14g: @xml_document.at("NetCTCODCAfterLimitAmt")&.text, #14g
      Line14h: @xml_document.at("NonrefundableODCAmt")&.text, #14h
      CtcOwed14i: @xml_document.at("RefundableCTCAmt")&.text, #14i
    }
  end
end
