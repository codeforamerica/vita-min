class Irs8812Pdf
  include PdfHelper

  def source_pdf_name
    "f8812-TY2021"
  end

  def initialize(submission)
    @submission = submission
    @qualifying_dependents = submission.tax_return.qualifying_dependents
    @benefits = Efile::BenefitsEligibility.new(tax_return: @tax_return, dependents: @qualifying_dependents)
  end

  def hash_for_pdf
    {
      AdjustedGrossIncomeAmt: 0, # 1
      ExcldSect933PuertoRicoIncmAmt: 0, # 2a
      GrossIncomeExclusionAmt: 0, # 2c
      AdditionalIncomeAdjAmt: 0, #2d
      ModifiedAGIAmt: 0, #3
      QlfyChildUnderAgeSSNCnt: @qualifying_dependents.select {|d| d.qualifying_ctc? }.length, #4a
      QlfyChildIncldUnderAgeSSNCnt: @qualifying_dependents.select { |d| d.qualifying_ctc? && d.age_during_tax_year < 6 }.length, #4b
      QlfyChildOverAgeSSNCnt: @qualifying_dependents.select { |d| d.qualifying_ctc? && d.age_during_tax_year >= 6 }.length, #4c
      MaxCTCAfterLimitAmt: @benefits.ctc_amount, #5
      OtherDependentCnt: @benefits.odc_amount / 500, #6
      OtherDependentCreditAmt: @benefits.odc_amount, #7
      InitialCTCODCAmt: @benefits.odc_amount + @benefits.ctc_amount, #8
      FilingStatusThresholdCd: @submission.tax_return.filing_jointly? ? "400000" : "200000", #9
      ExcessAdjGrossIncomeAmt: 0, #10
      ModifiedAGIPhaseOutAmt: 0, #11
      CTCODCAfterAGILimitAmt: @benefits.odc_amount + @benefits.ctc_amount, #12 (=8)
      MainHomeInUSOverHalfYrInd: 'X', #13a
      ODCAfterAGILimitAmt: @benefits.odc_amount, #14a (=7)
      CTCAfterAGILimitAmt: @benefits.ctc_amount, #14b (=5)
      RCTCTaxLiabiltyLimitAmt: 0, #14c
      ODCAfterTaxLiabilityLimitAmt: 0, #14d
      CTCODCAfterTaxLiabilityLmtAmt: 0, #14e
      AggregateAdvncCTCAmt: @benefits.advance_ctc_amount_received, #14f
      NetCTCODCAfterLimitAmt: @benefits.outstanding_ctc_amount, #14g
      NonrefundableODCAmt: 0, #14h
      RefundableCTCAmt: @benefits.outstanding_ctc_amount, #14i
    }
  end
end