module SubmissionBuilder
  module TY2021
    class LapsedFilerIrs1040 < SubmissionBuilder::Base
      include SubmissionBuilder::FormattingMethods
      @root_node = "IRS1040"

      def schema_file
        File.join(Rails.root, "vendor", "irs", "unpacked", @schema_version, "IndividualIncomeTax", "Ind1040", "IRS1040", "IRS1040.xsd")
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

        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.IRS1040(root_node_attrs) {
            xml.IndividualReturnFilingStatusCd tax_return.filing_status_code
            xml.VirtualCurAcquiredDurTYInd false
            xml.TotalExemptPrimaryAndSpouseCnt filer_exemption_count
            qualifying_dependents.each do |dependent|
              dependent_xml(xml, dependent)
            end
            xml.ChldWhoLivedWithYouCnt qualifying_dependents.count { |qd| qd.qualifying_child? }
            xml.OtherDependentsListedCnt qualifying_dependents.count { |qd| qd.qualifying_relative? }

            xml.TotalExemptionsCnt filer_exemption_count + qualifying_dependents.length
            xml.TotalItemizedOrStandardDedAmt tax_return.standard_deduction # line 12a in 2021v5.2/IndividualIncomeTax/Ind1040/IRS1040/IRS1040.xsd
            xml.TotDedCharitableContriAmt tax_return.standard_deduction # 12c
            xml.TotalDeductionsAmt tax_return.standard_deduction # 14
            xml.TaxableIncomeAmt 0 # 15

            # Line 28: remaining amount of CTC they are claiming (as determined in flow and listed on 8812 14i
            claimed_child_tax_credit = "0" # TODO: eventually replace this amount with the adv_ctc_amount_received when this is set in the RRC stories
            xml.RefundableCTCOrACTCAmt claimed_child_tax_credit # 28
            # maybe add this to be part of the stories for RRC

            # Line 30: remaining amount of RRC they are claiming for EIP-3
            xml.RecoveryRebateCreditAmt benefits.claimed_recovery_rebate_credit # 30

            # Line 32, 33, 34, 35a: Line 28 + Line 30
            total_payments = (claimed_child_tax_credit.to_i + benefits.claimed_recovery_rebate_credit.to_i).to_s
            xml.RefundableCreditsAmt total_payments # 32
            xml.TotalPaymentsAmt total_payments # 33
            xml.OverpaidAmt total_payments # 34
            xml.RefundAmt total_payments # 35a

            if bank_account.present? && intake.refund_payment_method_direct_deposit?
              xml.RoutingTransitNum account_number_type(bank_account.routing_number) # 35b
              xml.BankAccountTypeCd bank_account.account_type_code # 35c
              xml.DepositorAccountNum account_number_type(bank_account.account_number) # 35d
            end
            xml.RefundProductCd "NO FINANCIAL PRODUCT"
          }
        end.doc
      end

      def build
        unless ENV['TEST_SCHEMA_VALIDITY_ONLY'] == 'true'
          raise NotImplementedError, "SubmissionBuilder::TY2021::LapsedFilerIrs1040 is for testing purposes only and does not currently conform to the 2021 revenue procedure."
        end
        
        super
      end
    end
  end
end
