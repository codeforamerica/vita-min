module SubmissionBuilder
  module Ty2022
    module States
      module Ny
        module Documents
          class It201 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods
            FILING_STATUSES = {
              single: 1,
              married_filing_jointly: 2,
              married_filing_separately: 3,
              head_of_household: 4,
              qualifying_widow: 5,
            }.freeze
            NYC_RES = {
              yes: 1,
              no: 2
            }.freeze

            def document
              build_xml_doc("IT201") do |xml|
                xml.PR_DOB_DT claimed: intake.primary.birth_date.strftime("%Y-%m-%d") if intake.primary.birth_date.present?
                xml.FS_CD claimed: FILING_STATUSES[intake.filing_status.to_sym] if intake.filing_status.present?
                xml.FED_ITZDED_IND claimed: 2 # Always 2 == NO
                xml.DEP_CLAIM_IND claimed: intake.direct_file_data.claimed_as_dependent? ? 1 : 2 # 1 == YES, 2 == NO
                xml.FORGN_ACCT_IND claimed: 2 # Always 2 == NO
                xml.YNK_LVNG_QTR_IND claimed: 2 # Always 2 == NO
                xml.YNK_WRK_LVNG_IND claimed: 2 # Always 2 == NO
                if intake.nyc_residency_full_year?
                  xml.PR_NYC_MNTH_NMBR claimed: 12
                  xml.SP_NYC_MNTH_NMBR claimed: 12 if intake.filing_status_mfj?
                elsif intake.nyc_residency_none? && intake.nyc_maintained_home_no?
                  xml.NYC_LVNG_QTR_IND claimed: 2
                end
                add_non_zero_claimed_value(xml, :WG_AMT, :IT201_LINE_1)
                add_non_zero_claimed_value(xml, :INT_AMT, :IT201_LINE_2)
                add_non_zero_claimed_value(xml, :TX_UNEMP_AMT, :IT201_LINE_14)
                add_non_zero_claimed_value(xml, :SSINC_AMT, :IT201_LINE_15)
                add_non_zero_claimed_value(xml, :FEDAGI_B4_ADJ_AMT, :IT201_LINE_17)
                add_non_zero_claimed_value(xml, :FEDADJ_AMT, :IT201_LINE_18)
                add_non_zero_claimed_value(xml, :FEDAGI_AMT, :IT201_LINE_19)
                add_non_zero_claimed_value(xml, :A_PBEMP_AMT, :IT201_LINE_21)
                add_non_zero_claimed_value(xml, :A_SUBTL_AMT, :IT201_LINE_24)
                add_non_zero_claimed_value(xml, :S_TXBL_SS_AMT, :IT201_LINE_27)
                add_non_zero_claimed_value(xml, :S_SUBTL_AMT, :IT201_LINE_32)
                add_non_zero_claimed_value(xml, :NYSAGI_AMT, :IT201_LINE_33)
                xml.STD_ITZ_IND claimed: 1
                add_non_zero_claimed_value(xml, :DED_AMT, :IT201_LINE_34)
                add_non_zero_claimed_value(xml, :INC_B4_EXMPT_AMT, :IT201_LINE_35)
                if calculated_fields.fetch(:IT201_LINE_36) != 0
                  xml.EXMPT_NMBR claimed: calculated_fields.fetch(:IT201_LINE_36)
                end
                add_non_zero_claimed_value(xml, :TXBL_INC_AMT, :IT201_LINE_37)
                add_non_zero_claimed_value(xml, :TX_B4CR_AMT, :IT201_LINE_39)
                add_non_zero_claimed_value(xml, :HH_CR_AMT, :IT201_LINE_40)
                add_non_zero_claimed_value(xml, :TOT_NRFNDCR_AMT, :IT201_LINE_43)
                add_non_zero_claimed_value(xml, :TX_AFT_NRFNDCR_AMT, :IT201_LINE_44)
                add_non_zero_claimed_value(xml, :TOT_TX_AMT, :IT201_LINE_46)
                add_non_zero_claimed_value(xml, :NYC_TXBL_INC_AMT, :IT201_LINE_47)
                add_non_zero_claimed_value(xml, :NYC_TX_B4CR_AMT, :IT201_LINE_47A)
                add_non_zero_claimed_value(xml, :NYC_HH_CR_AMT, :IT201_LINE_48)
                add_non_zero_claimed_value(xml, :NYC_TX_AFT_HH_AMT, :IT201_LINE_49)
                add_non_zero_claimed_value(xml, :NYC_TOT_TX_AMT, :IT201_LINE_52)
                add_non_zero_claimed_value(xml, :NYC_TAX_AFT_CR_AMT, :IT201_LINE_54)
                add_non_zero_claimed_value(xml, :NYC_YNK_NET_TX_AMT, :IT201_LINE_58)
                # This field must be populated even when zero
                xml.SALE_USE_AMT claimed: calculated_fields.fetch(:IT201_LINE_59) || 0
                add_non_zero_claimed_value(xml, :TX_GFT_AMT, :IT201_LINE_61)
                add_non_zero_claimed_value(xml, :ESC_CHLD_CR_AMT, :IT201_LINE_63)
                add_non_zero_claimed_value(xml, :EITC_CR_AMT, :IT201_LINE_65)
                add_non_zero_claimed_value(xml, :RL_PROP_CR_AMT, :IT201_LINE_67)
                add_non_zero_claimed_value(xml, :NYC_STAR_CR_AMT, :IT201_LINE_69)
                add_non_zero_claimed_value(xml, :NYC_STAR_REDCR_AMT, :IT201_LINE_69A)
                add_non_zero_claimed_value(xml, :NYC_EITC_CR_AMT, :IT201_LINE_70)
                add_non_zero_claimed_value(xml, :TOT_WTHLD_AMT, :IT201_LINE_72)
                add_non_zero_claimed_value(xml, :TOT_NYC_WTHLD_AMT, :IT201_LINE_73)
                add_non_zero_claimed_value(xml, :TOT_PAY_AMT, :IT201_LINE_76)
                add_non_zero_claimed_value(xml, :OVR_PAID_AMT, :IT201_LINE_77)
                add_non_zero_claimed_value(xml, :RFND_B4_EDU_AMT, :IT201_LINE_78)
                add_non_zero_claimed_value(xml, :RFND_AMT, :IT201_LINE_78B)
                xml.PR_SGN_IND claimed: 1
                if @submission.data_source.spouse_esigned_yes?
                  xml.SP_SGN_IND claimed: 1
                end
                if intake.email_address.present?
                  xml.TP_EMAIL_ADR claimed: intake.email_address
                elsif intake.direct_file_data.tax_payer_email.present?
                  xml.TP_EMAIL_ADR claimed: intake.direct_file_data.tax_payer_email
                end
                if intake.direct_file_data.fed_adjustments_claimed.present?
                  xml.IT201FEDADJID do
                    intake.direct_file_data.fed_adjustments_claimed.each do |_type, info|
                      xml.descAmt do
                        xml.DESCRIPTION claimed: info[:xml_label] if info[:xml_label].present?
                        xml.AMOUNT claimed: info[:amount] if info[:amount].present?
                      end
                    end
                  end
                end
                if intake.dependents.present?
                  xml.IT201DepExmpInfo do
                    intake.dependents.each do |dependent|
                      xml.depInfo do
                        xml.DEP_CHLD_FRST_NAME claimed: dependent.first_name if dependent.first_name.present?
                        xml.DEP_CHLD_MI_NAME claimed: dependent.middle_initial if dependent.middle_initial.present?
                        xml.DEP_CHLD_LAST_NAME claimed: dependent.last_name if dependent.last_name.present?
                        xml.DEP_RELATION_DESC claimed: dependent.relationship.delete(" ") if dependent.relationship.present?
                        xml.DEP_SSN_NMBR claimed: dependent.ssn if dependent.ssn.present?
                        xml.DOB_DT claimed: dependent.dob.strftime("%Y-%m-%d") if dependent.dob.present?
                      end
                    end
                  end
                end
              end
            end

            private

            def intake
              @submission.data_source
            end

            def calculated_fields
              @it201_fields ||= intake.tax_calculator.calculate
            end
          end
        end
      end
    end
  end
end
 