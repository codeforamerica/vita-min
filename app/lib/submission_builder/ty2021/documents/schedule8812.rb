module SubmissionBuilder
  module Ty2021
    module Documents
      class Schedule8812 < SubmissionBuilder::Document
        def schema_file
          SchemaFileLoader.load_file("irs", "unpacked", @schema_version, "IndividualIncomeTax", "Common", "IRS1040Schedule8812", "IRS1040Schedule8812.xsd")
        end

        def document
          tax_return = submission.tax_return
          dependents = submission.qualifying_dependents
          benefits_eligibility = Efile::BenefitsEligibility.new(tax_return: tax_return, dependents: submission.qualifying_dependents)
          ctc_qualifying_dependents = dependents.select(&:qualifying_ctc?)
          home_location_puerto_rico = submission.intake.home_location_puerto_rico?
          build_xml_doc("IRS1040Schedule8812", documentId: "IRS1040Schedule8812", documentName: "IRS1040Schedule8812") do |xml|
            xml.AdjustedGrossIncomeAmt 0 unless home_location_puerto_rico  # 1
            xml.ExcldSect933PuertoRicoIncmAmt 0 unless home_location_puerto_rico # 2a
            xml.GrossIncomeExclusionAmt 0 unless home_location_puerto_rico # 2c
            xml.AdditionalIncomeAdjAmt 0 unless home_location_puerto_rico #2d
            xml.ModifiedAGIAmt 0 unless home_location_puerto_rico #3
            xml.QlfyChildUnderAgeSSNCnt ctc_qualifying_dependents.length #4a
            xml.QlfyChildIncldUnderAgeSSNCnt ctc_qualifying_dependents.count { |d| d.age_during_tax_year < 6 } #4b
            xml.QlfyChildOverAgeSSNCnt ctc_qualifying_dependents.count { |d| d.age_during_tax_year >= 6 } #4c
            xml.MaxCTCAfterLimitAmt benefits_eligibility.ctc_amount #5
            xml.OtherDependentCnt (benefits_eligibility.odc_amount / 500) unless benefits_eligibility.odc_amount.nil? #6
            xml.OtherDependentCreditAmt benefits_eligibility.odc_amount unless benefits_eligibility.odc_amount.nil? #7
            xml.InitialCTCODCAmt benefits_eligibility.odc_amount.to_i + benefits_eligibility.ctc_amount #8
            xml.FilingStatusThresholdCd submission.tax_return.filing_jointly? ? "400000" : "200000" #9
            xml.ExcessAdjGrossIncomeAmt 0 unless home_location_puerto_rico #10
            xml.ModifiedAGIPhaseOutAmt 0 unless home_location_puerto_rico #11
            xml.CTCODCAfterAGILimitAmt benefits_eligibility.odc_amount.to_i + benefits_eligibility.ctc_amount #12 (=8)
            xml.MainHomeInUSOverHalfYrInd 'X' unless home_location_puerto_rico #13a
            xml.BonaFidePRResidentInd 'X' if home_location_puerto_rico #13b
            xml.FilersWhoCheckBoxSpcfdGrp {
              xml.ODCAfterAGILimitAmt benefits_eligibility.odc_amount unless benefits_eligibility.odc_amount.nil? #14a (=7)
              xml.CTCAfterAGILimitAmt benefits_eligibility.ctc_amount #14b (=5)
              xml.RCTCTaxLiabiltyLimitAmt 0 unless home_location_puerto_rico #14c
              xml.ODCAfterTaxLiabilityLimitAmt 0 unless home_location_puerto_rico #14d
              xml.CTCODCAfterTaxLiabilityLmtAmt benefits_eligibility.ctc_amount #14e (=5)
              xml.AggregateAdvncCTCAmt benefits_eligibility.advance_ctc_amount_received #14f
              xml.NetCTCODCAfterLimitAmt benefits_eligibility.outstanding_ctc_amount #14g
              xml.NonrefundableODCAmt 0 unless home_location_puerto_rico #14h
              xml.RefundableCTCAmt benefits_eligibility.outstanding_ctc_amount #14i
            }
          end
        end
      end
    end
  end
end
