require "rails_helper"

RSpec.describe Irs8812Pdf do
  include PdfSpecHelper

  let(:pdf) { described_class.new(submission) }
  # Locked to 2021 because the resulting PDF matches 2021 revenue procedure needs.
  let(:submission) { create :efile_submission, :ctc, tax_year: 2021 }

  describe "#output_file" do
    context "with an empty submission record" do
      # "clear out" submission so we can see the empty state of the PDF
      before do
        submission.intake.update(advance_ctc_amount_received: 0)
        submission.intake.dependents.destroy_all
        submission.reload
      end

      it "returns a pdf with default fields and values" do
        output_file = pdf.output_file
        result = non_preparer_fields(output_file.path)
        expect(result).to match({
                                  "AdjustedGrossIncomeAmt" => "0", # 1
                                  "ExcldSect933PuertoRicoIncmAmt" => "0", # 2a
                                  "GrossIncomeExclusionAmt" => "0", # 2c
                                  "AdditionalIncomeAdjAmt" => "0", #2d
                                  "ModifiedAGIAmt" => "0", #3
                                  "QlfyChildUnderAgeSSNCnt" => "0", #4a
                                  "QlfyChildIncldUnderAgeSSNCnt" => "0", #4b
                                  "QlfyChildOverAgeSSNCnt" => "0", #4c
                                  "MaxCTCAfterLimitAmt" => "0", #5
                                  "OtherDependentCnt" => "0", #6
                                  "OtherDependentCreditAmt" => "0", #7
                                  "InitialCTCODCAmt" => "0", #8
                                  "FilingStatusThresholdCd" => "200000", #9
                                  "ExcessAdjGrossIncomeAmt" => "0", #10
                                  "ModifiedAGIPhaseOutAmt" => "0", #11
                                  "CTCODCAfterAGILimitAmt" => "0", #12 (=8)
                                  "MainHomeInUSOverHalfYrInd" => 'X', #13a
                                  "ODCAfterAGILimitAmt" => "0", #14a (=7)
                                  "CTCAfterAGILimitAmt" => "0", #14b (=5)
                                  "RCTCTaxLiabiltyLimitAmt" => "0", #14c
                                  "ODCAfterTaxLiabilityLimitAmt" => "0", #14d
                                  "CTCODCAfterTaxLiabilityLmtAmt" => "0", #14e
                                  "AggregateAdvncCTCAmt" => "0", #14f
                                  "NetCTCODCAfterLimitAmt" => "0", #14g
                                  "NonrefundableODCAmt" => "0", #14h
                                  "RefundableCTCAmt" => "0", #14i
                                })
      end
    end

    context "with a filled out submission record with qualifying dependents" do
      let(:daughter) do
        create :qualifying_child,
               first_name: "Danielle",
               last_name: "Dob",
               ssn: "123456789",
               relationship: "daughter",
               birth_date: Date.new(2012, 2, 25)
      end
      let(:son) do
        create :qualifying_child,
               first_name: "Daniel",
               last_name: "Dob",
               ssn: "123456788",
               relationship: "son",
               birth_date: Date.new(2016, 2, 26)
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
        allow(submission.tax_return).to receive(:qualifying_dependents).and_return([daughter, son, mother])
      end

      it "returns a filled out pdf" do
        output_file = pdf.output_file
        result = non_preparer_fields(output_file.path)
        expect(result).to match(hash_including(
                                  "AdjustedGrossIncomeAmt" => "0", # 1
                                  "ExcldSect933PuertoRicoIncmAmt" => "0", # 2a
                                  "GrossIncomeExclusionAmt" => "0", # 2c
                                  "AdditionalIncomeAdjAmt" => "0", #2d
                                  "ModifiedAGIAmt" => "0", #3
                                  "QlfyChildUnderAgeSSNCnt" => "1", #4a
                                  "QlfyChildIncldUnderAgeSSNCnt" => "1", #4b
                                  "QlfyChildOverAgeSSNCnt" => "1", #4c
                                  "MaxCTCAfterLimitAmt" => "", #5
                                  "OtherDependentCnt" => "", #6
                                  "OtherDependentCreditAmt" => "", #7
                                  "InitialCTCODCAmt" => "", #8
                                  "FilingStatusThresholdCd" => "200000", #9
                                  "ExcessAdjGrossIncomeAmt" => "", #10
                                  "ModifiedAGIPhaseOutAmt" => "", #11
                                  "CTCODCAfterAGILimitAmt" => "", #12 (=8)
                                  "MainHomeInUSOverHalfYrInd" => 'X', #13a
                                  "ODCAfterAGILimitAmt" => "", #14a (=7)
                                  "CTCAfterAGILimitAmt" => "", #14b (=5)
                                  "RCTCTaxLiabiltyLimitAmt" => "", #14c
                                  "ODCAfterTaxLiabilityLimitAmt" => "", #14d
                                  "CTCODCAfterTaxLiabilityLmtAmt" => "", #14e
                                  "AggregateAdvncCTCAmt" => "", #14f
                                  "NetCTCODCAfterLimitAmt" => "", #14g
                                  "NonrefundableODCAmt" => "", #14h
                                  "RefundableCTCAmt" => "", #14i
                                ))
      end
    end

    context "when status is married filing jointly" do
      before do
        submission.tax_return.update(filing_status: "married_filing_jointly")
        submission.reload
      end

      it "includes the correct filing status threshold" do
        output_file = pdf.output_file
        result = non_preparer_fields(output_file.path)
        expect(result).to match(hash_including(
                                  "FilingStatusThresholdCd" => "400000", #9
                                ))
      end
    end
  end
end