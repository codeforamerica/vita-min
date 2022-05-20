class Irs8812Ty2021Pdf
  include PdfHelper

  def source_pdf_name
    "f8812-TY2021"
  end

  def initialize(submission)
    @xml_document = SubmissionBuilder::Ty2021::Documents::Schedule8812.new(submission).document
  end

  def hash_for_pdf
    {
      AdjustedGrossIncomeAmt1: 0, # 1
      PRExcludedIncomeAmt2a: 0, # 2a
      GrossIncomeExclusionAmt2c: 0, # 2c
      ExclusionsTotalAmt2d: 0, #2d
      AGIExclusionsTotalAmt3: 0, #3
      NumQCSsn4a: @xml_document.at("QlfyChildUnderAgeSSNCnt")&.text, #4a
      NumQCOverSix4b: @xml_document.at("QlfyChildIncldUnderAgeSSNCnt")&.text, #4b
      NumQCUnderSix4c: @xml_document.at("QlfyChildOverAgeSSNCnt")&.text, #4c
      TotalCtcAmt5: @xml_document.at("MaxCTCAfterLimitAmt")&.text, #5
      NumNonCtcDependents6: @xml_document.at("OtherDependentCnt")&.text, #6
      OtherDependentCreditAmt7: @xml_document.at("OtherDependentCreditAmt")&.text, #7
      TotalCreditAmt8: @xml_document.at("InitialCTCODCAmt")&.text, #8
      FilingStatusIncomeLimit9: @xml_document.at("FilingStatusThresholdCd")&.text, #9
      Line10: 0, #10
      Line11: 0, #11
      TotalCreditAmt12: @xml_document.at("CTCODCAfterAGILimitAmt")&.text, #12 (=8)
      USHomeInd13a: 'X', #13a
      OtherDependentCreditAmt14a: @xml_document.at("ODCAfterAGILimitAmt")&.text, #14a (=7)
      TotalCtcAmt14b: @xml_document.at("CTCAfterAGILimitAmt")&.text, #14b (=5)
      Line14c: 0, #14c
      Line14d: 0, #14d
      TotalCtcAmt14e: @xml_document.at("CTCODCAfterTaxLiabilityLmtAmt")&.text, #14e (=5)
      AdvCtcReceived14f: @xml_document.at("AggregateAdvncCTCAmt")&.text, #14f
      CtcOwed14g: @xml_document.at("NetCTCODCAfterLimitAmt")&.text, #14g
      Line14h: 0, #14h
      CtcOwed14i: @xml_document.at("RefundableCTCAmt")&.text, #14i
    }
  end
end
