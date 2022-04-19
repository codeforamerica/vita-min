class Irs8812Pdf
  include PdfHelper

  def source_pdf_name
    "f8812-TY2021"
  end

  def initialize(submission)
    @submission = submission
    @qualifying_dependents = submission.qualifying_dependents
    @benefits = Efile::BenefitsEligibility.new(tax_return: submission.tax_return, dependents: @qualifying_dependents)
  end

  def hash_for_pdf
    {
      AdjustedGrossIncomeAmt1: 0, # 1
      PRExcludedIncomeAmt2a: 0, # 2a
      GrossIncomeExclusionAmt2c: 0, # 2c
      ExclusionsTotalAmt2d: 0, #2d
      AGIExclusionsTotalAmt3: 0, #3
      NumQCSsn4a: @qualifying_dependents.select {|d| d.qualifying_ctc? }.length, #4a
      NumQCOverSix4b: @qualifying_dependents.select { |d| d.qualifying_ctc? && d.age_during_tax_year < 6 }.length, #4b
      NumQCUnderSix4c: @qualifying_dependents.select { |d| d.qualifying_ctc? && d.age_during_tax_year >= 6 }.length, #4c
      TotalCtcAmt5: @benefits.ctc_amount, #5
      NumNonCtcDependents6: @benefits.odc_amount / 500, #6
      OtherDependentCreditAmt7: @benefits.odc_amount, #7
      TotalCreditAmt8: @benefits.odc_amount + @benefits.ctc_amount, #8
      FilingStatusIncomeLimit9: @submission.tax_return.filing_jointly? ? "400000" : "200000", #9
      Line10: 0, #10
      Line11: 0, #11
      TotalCreditAmt12: @benefits.odc_amount + @benefits.ctc_amount, #12 (=8)
      USHomeInd13a: 'X', #13a
      OtherDependentCreditAmt14a: @benefits.odc_amount, #14a (=7)
      TotalCtcAmt14b: @benefits.ctc_amount, #14b (=5)
      Line14c: 0, #14c
      Line14d: 0, #14d
      TotalCtcAmt14e: 0, #14e
      AdvCtcReceived14f: @benefits.advance_ctc_amount_received, #14f
      CtcOwed14g: @benefits.outstanding_ctc_amount, #14g
      Line14h: 0, #14h
      CtcOwed14i: @benefits.outstanding_ctc_amount, #14i
    }
  end
end