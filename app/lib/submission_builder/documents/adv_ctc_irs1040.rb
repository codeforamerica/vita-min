module SubmissionBuilder
  module Documents
    class AdvCtcIrs1040 < SubmissionBuilder::Base
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
          xml.DependentNameControlTxt person_name_control_type(dependent.first_name)
          xml.DependentSSN dependent.ssn
          xml.DependentRelationshipCd dependent.irs_relationship_enum
          xml.EligibleForChildTaxCreditInd "X" if dependent.eligible_for_child_tax_credit_2020?
        end
      end

      def filer_exemption_count
        submission.tax_return.filing_jointly? ? 2 : 1
      end

      def document
        intake = submission.intake
        tax_return = submission.tax_return
        bank_account = intake.bank_account
        qualifying_dependents = tax_return.qualifying_dependents

        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.IRS1040(root_node_attrs) {
            xml.IndividualReturnFilingStatusCd tax_return.filing_status_code
            xml.VirtualCurAcquiredDurTYInd false
            xml.TotalExemptPrimaryAndSpouseCnt filer_exemption_count
            qualifying_dependents.each do |dependent|
              dependent_xml(xml, dependent)
            end
            xml.ChldWhoLivedWithYouCnt qualifying_dependents.count(&:qualifying_child_2020?)
            xml.OtherDependentsListedCnt qualifying_dependents.count(&:qualifying_relative_2020?)
            xml.TotalExemptionsCnt filer_exemption_count + qualifying_dependents.length
            xml.TaxableInterestAmt 1 # 2b
            xml.TotalIncomeAmt 1 # 9
            xml.AdjustedGrossIncomeAmt 1 # 11
            xml.TotalItemizedOrStandardDedAmt tax_return.standard_deduction
            xml.TaxableIncomeAmt 0
            xml.RecoveryRebateCreditAmt tax_return.claimed_recovery_rebate_credit
            xml.RefundableCreditsAmt tax_return.claimed_recovery_rebate_credit
            xml.TotalPaymentsAmt 0
            xml.OverpaidAmt 0
            xml.RefundAmt tax_return.claimed_recovery_rebate_credit
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