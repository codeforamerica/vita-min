module SubmissionBuilder
  module Documents
    class Scenario5Irs1040 < SubmissionBuilder::Base
      include SubmissionBuilder::FormattingMethods

      @schema_file = File.join(Rails.root, "vendor", "irs", "unpacked", "2020v5.1", "IndividualIncomeTax", "Ind1040", "IRS1040", "IRS1040.xsd")
      @root_node = "IRS1040"

      def root_node_attrs
        super.merge(documentId: "IRS1040", documentName: "IRS1040")
      end

      def dependent_xml(xml, dependent)
        xml.DependentDetail do
          xml.DependentFirstNm dependent.first_name
          xml.DependentLastNm dependent.last_name
          xml.DependentNameControlTxt person_name_control_type(dependent.last_name)
          xml.DependentSSN dependent.ssn
          xml.DependentRelationshipCd dependent.relationship&.upcase
          xml.EligibleForChildTaxCreditInd "X" # both dependents in scenario are eligible for CTC
        end
      end

      def filer_exemption_count
        submission.tax_return.filing_jointly? ? 2 : 1
      end

      def total_exemption_count
        filer_exemption_count + submission.dependents.count # TODO: Narrow this down to "qualifying" dependents
      end

      def document
        intake = submission.intake
        tax_return = submission.tax_return
        bank_account = intake.bank_account
        dependents = intake.dependents

        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.IRS1040(root_node_attrs) {
            xml.IndividualReturnFilingStatusCd tax_return.filing_status_code
            xml.VirtualCurAcquiredDurTYInd false
            xml.TotalExemptPrimaryAndSpouseCnt filer_exemption_count
            dependents.each do |dependent|
              dependent_xml(xml, dependent)
            end
            xml.ChldWhoLivedWithYouCnt dependents.count # TODO: Update with "Qualifying Child" count
            xml.OtherDependentsListedCnt 0 # TODO: Update with "Qualifying Relative" count
            xml.TotalExemptionsCnt total_exemption_count
            xml.WagesSalariesAndTipsAmt 30169
            # xml.TaxableInterestAmt 0
            xml.TotalIncomeAmt 30169
            xml.TotalAdjustmentsAmt 1300
            xml.TotalAdjustmentsToIncomeAmt 1300
            xml.AdjustedGrossIncomeAmt 28869
            xml.TotalItemizedOrStandardDedAmt 24800
            xml.TotalDeductionsAmt 24800
            xml.TaxableIncomeAmt 406
            xml.TaxAmt 408
            xml.TotalTaxBeforeCrAndOthTaxesAmt 408
            xml.TotalNonrefundableCreditsAmt 408
            xml.TotalCreditsAmt 408
            xml.TaxLessCreditsAmt 0
            xml.TotalOtherTaxesAmt 0
            xml.TotalTaxAmt 0
            xml.FormW2WithheldTaxAmt 2110
            xml.WithholdingTaxAmt 2110
            xml.EarnedIncomeCreditAmt 3636
            xml.PYEarnedIncmAdditonalChldTxGrp {
              xml.PriorYearEarnedIncomeCd "PYEI"
              xml.PriorYearEarnedIncomeAmt 2800
            }
            xml.AdditionalChildTaxCreditAmt 2800
            xml.RefundableAmerOppCreditAmt 280
            xml.RecoveryRebateCreditAmt 400
            xml.RefundableCreditsAmt 7116
            xml.TotalPaymentsAmt 9226
            xml.OverpaidAmt 9226
            xml.RefundAmt 9226
            if bank_account.present? && intake.refund_payment_method_direct_deposit?
              xml.RoutingTransitNum bank_account.routing_number
              xml.BankAccountTypeCd bank_account.account_type_code
              xml.DepositorAccountNum bank_account.account_number
            end
            xml.RefundProductCd "NO FINANCIAL PRODUCT"
          }
        end.doc
      end
    end
  end
end