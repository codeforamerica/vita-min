module SubmissionBuilder
  module Ty2020
    module Documents
      class Irs1040 < SubmissionBuilder::Document
        include SubmissionBuilder::FormattingMethods

        def schema_file
          SchemaFileLoader.load_file("irs", "unpacked", "2020v5.1", "IndividualIncomeTax", "Ind1040", "IRS1040", "IRS1040.xsd")
        end

        def dependent_xml(xml, dependent)
          xml.DependentDetail do
            xml.DependentFirstNm person_name_type(dependent.first_name)
            xml.DependentLastNm person_name_type(dependent.last_name)
            xml.DependentNameControlTxt name_control_type(dependent.last_name)
            xml.DependentSSN dependent.ssn
            xml.DependentRelationshipCd dependent.irs_relationship_enum
            xml.EligibleForChildTaxCreditInd "X" if dependent.qualifying_ctc?
          end
        end

        def filer_exemption_count
          submission.tax_return.filing_jointly? ? 2 : 1
        end

        def document
          intake = submission.intake
          tax_return = submission.tax_return
          bank_account = intake.bank_account
          qualifying_dependents = submission.qualifying_dependents
          benefits = Efile::BenefitsEligibility.new(tax_return: tax_return, dependents: qualifying_dependents)

          build_xml_doc("IRS1040", documentId: "IRS1040", documentName: "IRS1040") do |xml|
            xml.IndividualReturnFilingStatusCd tax_return.filing_status_code
            xml.VirtualCurAcquiredDurTYInd false
            xml.TotalExemptPrimaryAndSpouseCnt filer_exemption_count
            qualifying_dependents.each do |dependent|
              dependent_xml(xml, dependent)
            end
            xml.ChldWhoLivedWithYouCnt qualifying_dependents.count(&:qualifying_child?)
            xml.OtherDependentsListedCnt qualifying_dependents.count(&:qualifying_relative?)
            xml.TotalExemptionsCnt filer_exemption_count + qualifying_dependents.length
            xml.TaxableInterestAmt 1 # 2b
            xml.TotalIncomeAmt 1 # 9
            xml.AdjustedGrossIncomeAmt 1 # 11
            xml.TotalItemizedOrStandardDedAmt tax_return.standard_deduction # 12
            xml.TaxableIncomeAmt 0 # 15
            xml.RecoveryRebateCreditAmt benefits.claimed_recovery_rebate_credit # 30
            xml.RefundableCreditsAmt benefits.claimed_recovery_rebate_credit # 32
            xml.TotalPaymentsAmt benefits.claimed_recovery_rebate_credit # 33
            xml.OverpaidAmt benefits.claimed_recovery_rebate_credit # 34
            xml.RefundAmt benefits.claimed_recovery_rebate_credit # 35a
            if bank_account.present? && intake.refund_payment_method_direct_deposit?
              xml.RoutingTransitNum account_number_type(bank_account.routing_number)
              xml.BankAccountTypeCd bank_account.account_type_code
              xml.DepositorAccountNum account_number_type(bank_account.account_number)
            end
            xml.RefundProductCd "NO FINANCIAL PRODUCT"
          end
        end
      end
    end
  end
end
