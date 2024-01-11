module SubmissionBuilder
  module Ty2022
    module States
      module Ny
        module Documents
          class RtnHeader < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods
            ACCOUNT_TYPES = {
              unfilled: 0,
              checking: 1,
              savings: 2,
            }.freeze

            def document
              build_xml_doc("rtnHeader") do |xml|
                # xml.COND_CODE_1_NMBR
                # xml.COND_CODE_2_NMBR
                # xml.THRD_PRTY_DSGN_IND
                # xml.THRD_PRTY_PIN_NMBR
                xml.EXT_TP_ID claimed: @submission.data_source.primary.ssn
                unless @submission.data_source.routing_number.nil?
                  xml.ABA_NMBR claimed: @submission.data_source.routing_number
                end

                unless @submission.data_source.account_number.nil?
                  xml.BANK_ACCT_NMBR claimed: @submission.data_source.account_number.delete('-')
                end
                unless @submission.data_source.account_type.nil? || ACCOUNT_TYPES[@submission.data_source.account_type.to_sym] == 0
                  xml.ACCT_TYPE_CD claimed: ACCOUNT_TYPES[@submission.data_source.account_type.to_sym]
                end
                unless @submission.data_source.date_electronic_withdrawal.nil?
                  xml.ELC_AUTH_EFCTV_DT claimed: @submission.data_source.date_electronic_withdrawal
                end
                unless @submission.data_source.withdraw_amount.nil?
                  xml.PYMT_AMT claimed: @submission.data_source.withdraw_amount
                end
                xml.ACH_IND claimed: @submission.data_source.ach_debit_transaction? ? 1 : 2
                xml.RFND_OWE_IND claimed: @submission.data_source.payment_or_deposit_type == "direct_deposit" ? 1 : 2
                xml.BAL_DUE_AMT claimed: calculated_fields.fetch(:IT201_LINE_80)

                # xml.SBMSN_ID
                # xml.ELF_STATE_ONLY_IND
                # xml.PREP_LN_1_ADR
                # xml.PREP_CTY_ADR
                xml.SOFT_VNDR_ID
                # xml.FIRM_NAME
                # xml.PP_NAME
                # xml.PREP_SIGN_DT
                # xml.PREP_LN_2_ADR
                # xml.PREP_ST_ADR
                # xml.PREP_ZIP_4_ADR
                # xml.PREP_ZIP_5_ADR
                # xml.PREP_EIN_IND
                if @submission.data_source.phone_number&.present?
                  xml.AREACODE_NMBR claimed: @submission.data_source.phone_number[-10, 3]
                  xml.EXCHNG_PHONE_NMBR claimed: @submission.data_source.phone_number[-7, 3]
                  xml.DGT4_PHONE_NMBR claimed: @submission.data_source.phone_number[-4, 4]
                elsif @submission.data_source.direct_file_data.phone_number&.present?
                  xml.AREACODE_NMBR claimed: @submission.data_source.direct_file_data.phone_number[-10, 3]
                  xml.EXCHNG_PHONE_NMBR claimed: @submission.data_source.direct_file_data.phone_number[-7, 3]
                  xml.DGT4_PHONE_NMBR claimed: @submission.data_source.direct_file_data.phone_number[-4, 4]
                elsif @submission.data_source.direct_file_data.cell_phone_number&.present?
                  xml.AREACODE_NMBR claimed: @submission.data_source.direct_file_data.cell_phone_number[-10, 3]
                  xml.EXCHNG_PHONE_NMBR claimed: @submission.data_source.direct_file_data.cell_phone_number[-7, 3]
                  xml.DGT4_PHONE_NMBR claimed: @submission.data_source.direct_file_data.cell_phone_number[-4, 4]
                end
                # xml.DGT4_PHONE_NMBR
                xml.FORM_TYPE
                # xml.THRDPRTY_EMAIL_ADR
                # xml.EFIN_ID
                # xml.PP_PH_NMBR
                xml.IAT_IND
                # xml.ORIG_SBMSN_ID
                if @submission.data_source.spouse.present? && @submission.data_source.spouse.birth_date.present?
                  xml.SP_DOB_DT claimed: @submission.data_source.spouse.birth_date.strftime("%Y-%m-%d")
                end
                # xml.FREE_FIL_IND
                # xml.PR_SSN_VALID_IND
                # xml.SP_SSN_VALID_IND
                xml.BNK_ACCT_ACH_IND claimed: 2 #only personal banking accounts supported not business
                if @submission.data_source.payment_or_deposit_type == "direct_deposit"
                  xml.PAPER_CHK_RFND_IND claimed: 2
                  xml.DIR_DEP_IND claimed: 1
                else
                  xml.PAPER_CHK_RFND_IND claimed: 1
                  xml.DIR_DEP_IND claimed: 2
                end
                # xml.ITIN_MSMTCH_IND
                # xml.IMPRFCT_RTN_IND
              end
            end

            private

            def calculated_fields
              @calculated_fields ||= @submission.data_source.tax_calculator.calculate
            end
          end
        end
      end
    end
  end
end
