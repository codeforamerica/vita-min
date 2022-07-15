module SubmissionBuilder
  module Ty2021
    module Documents
      class Irs1040 < SubmissionBuilder::Document
        include SubmissionBuilder::FormattingMethods

        def schema_file
          File.join(Rails.root, "vendor", "irs", "unpacked", @schema_version, "IndividualIncomeTax", "Ind1040", "IRS1040", "IRS1040.xsd")
        end

        def document
          include_w2_detail = ENV['W2_SUPPORT'] == 'true'

          intake = submission.intake
          tax_return = submission.tax_return
          bank_account = intake.bank_account
          qualifying_dependents = submission.qualifying_dependents
          benefits = Efile::BenefitsEligibility.new(tax_return: tax_return, dependents: qualifying_dependents)
          boxes_checked = boxes_checked(intake, tax_return)

          build_xml_doc("IRS1040", documentId: "IRS1040", documentName: "IRS1040") do |xml|
            xml.IndividualReturnFilingStatusCd tax_return.filing_status_code
            xml.VirtualCurAcquiredDurTYInd intake.has_crypto_income
            xml.Primary65OrOlderInd "X" if tax_return.primary_age_65_or_older?
            xml.PrimaryBlindInd "X" if intake.was_blind_yes?
            xml.Spouse65OrOlderInd "X" if tax_return.spouse_age_65_or_older? && tax_return.filing_jointly?
            xml.SpouseBlindInd "X" if intake.spouse_was_blind_yes? && tax_return.filing_jointly?
            xml.TotalBoxesCheckedCnt boxes_checked unless boxes_checked.zero?
            xml.TotalExemptPrimaryAndSpouseCnt filer_exemption_count
            qualifying_dependents.each do |dependent|
              dependent_xml(xml, dependent)
            end
            xml.ChldWhoLivedWithYouCnt qualifying_dependents.count { |qd| qd.qualifying_child? }
            xml.OtherDependentsListedCnt qualifying_dependents.count { |qd| qd.qualifying_relative? }
            xml.TotalExemptionsCnt filer_exemption_count + qualifying_dependents.length

            if include_w2_detail
              xml.WagesSalariesAndTipsAmt 1000 # Line 1
              xml.TotalIncomeAmt 1000 # Line 9
              xml.AdjustedGrossIncomeAmt 1000 # line 11
            end

            if intake.home_location_puerto_rico?
              xml.TotalItemizedOrStandardDedAmt 0, {modifiedStandardDeductionInd: 'SECT 933'} # 12a
            else
              xml.TotalItemizedOrStandardDedAmt tax_return.standard_deduction # 12a
            end
            xml.TotDedCharitableContriAmt tax_return.standard_deduction unless tax_return.standard_deduction.nil? # 12c
            xml.TotalDeductionsAmt tax_return.standard_deduction unless tax_return.standard_deduction.nil? # 14
            xml.TaxableIncomeAmt 0 unless intake.home_location_puerto_rico? # 15

            if include_w2_detail
              xml.FormW2WithheldTaxAmt 100 # line 25a
              xml.WithholdingTaxAmt 100 # line 25d
              xml.EarnedIncomeCreditAmt 400 # line 27a amount
              xml.UndSpcfdAgeStsfyRqrEICInd "X" # line 27a checkbox
              # to do this right here's the rules: If 'NontxCombatPayElectionAmt' in the return has a non-zero value, then it must be equal to the sum of all Forms W-2, 'EmployersUseAmt' with corresponding 'EmployersUseCd' having the value "Q".
              # xml.NontxCombatPayElectionAmt 50 # line 27b
            end

            # Line 28: remaining amount of CTC they are claiming (as determined in flow and listed on 8812 14i
            xml.RefundableCTCOrACTCAmt benefits.outstanding_ctc_amount # 28

            # Line 30: remaining amount of RRC they are claiming for EIP-3
            xml.RecoveryRebateCreditAmt benefits.claimed_recovery_rebate_credit unless benefits.claimed_recovery_rebate_credit.nil? # 30

            total_refundable_credits = benefits.outstanding_ctc_amount + benefits.claimed_recovery_rebate_credit.to_i

            if include_w2_detail
              total_refundable_credits += 500 # also include EITC and withholding
            end

            # Line 32, 33, 34, 35a: Line 28 + Line 30
            xml.RefundableCreditsAmt total_refundable_credits # 32
            xml.TotalPaymentsAmt total_refundable_credits # 33
            xml.OverpaidAmt total_refundable_credits # 34
            xml.RefundAmt total_refundable_credits # 35a

            if bank_account.present? && intake.refund_payment_method_direct_deposit?
              xml.RoutingTransitNum account_number_type(bank_account.routing_number) # 35b
              xml.BankAccountTypeCd bank_account.account_type_code # 35c
              xml.DepositorAccountNum account_number_type(bank_account.account_number) # 35d
            end
            xml.RefundProductCd "NO FINANCIAL PRODUCT"
          end
        end

        private

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

        def boxes_checked(intake, tax_return)
          [intake.was_blind_yes?,
           tax_return.primary_age_65_or_older?,
           tax_return.spouse_age_65_or_older? && tax_return.filing_jointly?,
           intake.spouse_was_blind_yes? && tax_return.filing_jointly?
          ].count(true)
        end
      end
    end
  end
end
