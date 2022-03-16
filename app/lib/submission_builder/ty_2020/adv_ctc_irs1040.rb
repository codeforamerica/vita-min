module SubmissionBuilder
  module TY2020
    class AdvCtcIrs1040 < SubmissionBuilder::Base
      include SubmissionBuilder::FormattingMethods
      @root_node = "IRS1040"

      def schema_file
        File.join(Rails.root, "vendor", "irs", "unpacked", "2020v5.1", "IndividualIncomeTax", "Ind1040", "IRS1040", "IRS1040.xsd")
      end

      def root_node_attrs
        super.merge(documentId: "IRS1040", documentName: "IRS1040")
      end

      def dependent_xml(xml, dependent)
        xml.DependentDetail do
          xml.DependentFirstNm person_name_type(dependent.first_name)
          xml.DependentLastNm person_name_type(dependent.last_name)
          xml.DependentNameControlTxt person_name_control_type(dependent.last_name)
          xml.DependentSSN dependent.ssn
          xml.DependentRelationshipCd dependent.irs_relationship_enum
          xml.EligibleForChildTaxCreditInd "X" if dependent.eligible_for_child_tax_credit?(2020)
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
            xml.ChldWhoLivedWithYouCnt qualifying_dependents.count(&:yr_2020_qualifying_child?)
            xml.OtherDependentsListedCnt qualifying_dependents.count(&:yr_2020_qualifying_relative?)
            xml.TotalExemptionsCnt filer_exemption_count + qualifying_dependents.length
            xml.TaxableInterestAmt 1 # 2b
            xml.TotalIncomeAmt 1 # 9
            xml.AdjustedGrossIncomeAmt 1 # 11
            xml.TotalItemizedOrStandardDedAmt tax_return.standard_deduction # 12
            xml.TaxableIncomeAmt 0 # 15
            xml.RecoveryRebateCreditAmt tax_return.claimed_recovery_rebate_credit # 30
            xml.RefundableCreditsAmt tax_return.claimed_recovery_rebate_credit # 32
            xml.TotalPaymentsAmt tax_return.claimed_recovery_rebate_credit # 33
            xml.OverpaidAmt tax_return.claimed_recovery_rebate_credit # 34
            xml.RefundAmt tax_return.claimed_recovery_rebate_credit # 35a
            if bank_account.present? && intake.refund_payment_method_direct_deposit?
              xml.RoutingTransitNum account_number_type(bank_account.routing_number)
              xml.BankAccountTypeCd bank_account.account_type_code
              xml.DepositorAccountNum account_number_type(bank_account.account_number)
            end
            xml.RefundProductCd "NO FINANCIAL PRODUCT"
          }
        end.doc
      end
    end
  end
end
