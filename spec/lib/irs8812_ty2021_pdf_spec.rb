require "rails_helper"

RSpec.describe Irs8812Ty2021Pdf do
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
        expect(result).to match(hash_including(
                                  "AdjustedGrossIncomeAmt1" => "0", # 1
                                  "PRExcludedIncomeAmt2a" => "0", # 2a
                                  "GrossIncomeExclusionAmt2c" => "0", # 2c
                                  "ExclusionsTotalAmt2d" => "0", #2d
                                  "AGIExclusionsTotalAmt3" => "0", #3
                                  "NumQCSsn4a" => "0", #4a
                                  "NumQCOverSix4b" => "0", #4b
                                  "NumQCUnderSix4c" => "0", #4c
                                  "TotalCtcAmt5" => "0", #5
                                  "NumNonCtcDependents6" => "0", #6
                                  "OtherDependentCreditAmt7" => "0", #7
                                  "TotalCreditAmt8" => "0", #8
                                  "FilingStatusIncomeLimit9" => "200000", #9
                                  "Line10" => "0", #10
                                  "Line11" => "0", #11
                                  "TotalCreditAmt12" => "0", #12 (=8)
                                  "USHomeInd13a" => 'X', #13a
                                  "OtherDependentCreditAmt14a" => "0", #14a (=7)
                                  "TotalCtcAmt14b" => "0", #14b (=5)
                                  "Line14c" => "0", #14c
                                  "Line14d" => "0", #14d
                                  "TotalCtcAmt14e" => "0", #14e (=5)
                                  "AdvCtcReceived14f" => "0", #14f
                                  "CtcOwed14g" => "0", #14g
                                  "Line14h" => "0", #14h
                                  "CtcOwed14i" => "0", #14i
                                  ))
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
        submission.intake.update(dependents: [daughter, son, mother])
        submission.intake.dependents.each do |dependent|
          EfileSubmissionDependent.create_qualifying_dependent(submission, dependent)
        end
      end

      it "returns a filled out pdf" do
        output_file = pdf.output_file
        result = non_preparer_fields(output_file.path)
        expect(result).to match(hash_including(
                                  "AdjustedGrossIncomeAmt1" => "0", # 1
                                  "PRExcludedIncomeAmt2a" => "0", # 2a
                                  "GrossIncomeExclusionAmt2c" => "0", # 2c
                                  "ExclusionsTotalAmt2d" => "0", #2d
                                  "AGIExclusionsTotalAmt3" => "0", #3
                                  "NumQCSsn4a" => "2", #4a
                                  "NumQCOverSix4b" => "1", #4b
                                  "NumQCUnderSix4c" => "1", #4c
                                  "TotalCtcAmt5" => "6600", #5
                                  "NumNonCtcDependents6" => "1", #6
                                  "OtherDependentCreditAmt7" => "500", #7
                                  "TotalCreditAmt8" => "7100", #8
                                  "FilingStatusIncomeLimit9" => "200000", #9
                                  "Line10" => "0", #10
                                  "Line11" => "0", #11
                                  "TotalCreditAmt12" => "7100", #12 (=8)
                                  "USHomeInd13a" => 'X', #13a
                                  "OtherDependentCreditAmt14a" => "500", #14a (=7)
                                  "TotalCtcAmt14b" => "6600", #14b (=5)
                                  "Line14c" => "0", #14c
                                  "Line14d" => "0", #14d
                                  "TotalCtcAmt14e" => "6600", #14e (=5)
                                  "AdvCtcReceived14f" => "0", #14f
                                  "CtcOwed14g" => "6600", #14g
                                  "Line14h" => "0", #14h
                                  "CtcOwed14i" => "6600", #14i
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
                                  "FilingStatusIncomeLimit9" => "400000", #9
                                ))
      end
    end
  end
end
