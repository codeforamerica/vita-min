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
            REFUND_OR_OWE_TYPES = {
              none: 0,
              refund: 1,
              owe: 2,
            }.freeze

            def document
              build_xml_doc("rtnHeader") do |xml|
                xml.COND_CODE_1_NMBR claimed: "07" if @submission.data_source.filing_status_mfs? && !@submission.data_source.direct_file_data.spouse_ssn.present?
                # xml.COND_CODE_2_NMBR
                if @submission.data_source.confirmed_third_party_designee_yes?
                  xml.THRD_PRTY_DSGN_IND claimed: 1
                  xml.THRD_PRTY_PIN_NMBR claimed: @submission.data_source.direct_file_data.third_party_designee_pin.strip.gsub(/\s+/, ' ') if @submission.data_source.direct_file_data.third_party_designee_pin.present?
                end
                xml.EXT_TP_ID claimed: @submission.data_source.primary.ssn if @submission.data_source.primary.ssn.present?
                xml.ABA_NMBR claimed: @submission.data_source.routing_number.strip.gsub(/\s+/, ' ') if @submission.data_source.routing_number.present?
                xml.BANK_ACCT_NMBR claimed: @submission.data_source.account_number.delete('-') if @submission.data_source.account_number.present?
                if @submission.data_source.account_type.present? && ACCOUNT_TYPES[@submission.data_source.account_type.to_sym] != 0
                  xml.ACCT_TYPE_CD claimed: ACCOUNT_TYPES[@submission.data_source.account_type.to_sym]
                end
                # xml.ELC_AUTH_EFCTV_DT claimed: @submission.data_source.date_electronic_withdrawal if @submission.data_source.date_electronic_withdrawal.present?
                xml.PYMT_AMT claimed: @submission.data_source.withdraw_amount if @submission.data_source.withdraw_amount.present?
                xml.ACH_IND claimed: @submission.data_source.ach_debit_transaction? ? 1 : 2
                xml.RFND_OWE_IND claimed: REFUND_OR_OWE_TYPES[@submission.data_source.refund_or_owe_taxes_type]
                xml.BAL_DUE_AMT claimed: calculated_fields.fetch(:IT201_LINE_80) if calculated_fields.fetch(:IT201_LINE_80) != 0
                # xml.SBMSN_ID
                # xml.ELF_STATE_ONLY_IND
                # xml.PREP_LN_1_ADR
                # xml.PREP_CTY_ADR
                xml.SOFT_VNDR_ID claimed: "21013326"
                # xml.FIRM_NAME
                # xml.PP_NAME
                # xml.PREP_SIGN_DT
                # xml.PREP_LN_2_ADR
                # xml.PREP_ST_ADR
                # xml.PREP_ZIP_4_ADR
                # xml.PREP_ZIP_5_ADR
                # xml.PREP_EIN_IND
                if @submission.data_source.phone_number&.present?
                  xml.AREACODE_NMBR claimed: @submission.data_source.phone_number.delete(" ")[-10, 3]
                  xml.EXCHNG_PHONE_NMBR claimed: @submission.data_source.phone_number.delete(" ")[-7, 3]
                  xml.DGT4_PHONE_NMBR claimed: @submission.data_source.phone_number.delete(" ")[-4, 4]
                elsif @submission.data_source.direct_file_data.phone_number&.present?
                  xml.AREACODE_NMBR claimed: @submission.data_source.direct_file_data.phone_number.delete(" ")[-10, 3]
                  xml.EXCHNG_PHONE_NMBR claimed: @submission.data_source.direct_file_data.phone_number.delete(" ")[-7, 3]
                  xml.DGT4_PHONE_NMBR claimed: @submission.data_source.direct_file_data.phone_number.delete(" ")[-4, 4]
                elsif @submission.data_source.direct_file_data.cell_phone_number&.present?
                  xml.AREACODE_NMBR claimed: @submission.data_source.direct_file_data.cell_phone_number.delete(" ")[-10, 3]
                  xml.EXCHNG_PHONE_NMBR claimed: @submission.data_source.direct_file_data.cell_phone_number.delete(" ")[-7, 3]
                  xml.DGT4_PHONE_NMBR claimed: @submission.data_source.direct_file_data.cell_phone_number.delete(" ")[-4, 4]
                end
                # xml.DGT4_PHONE_NMBR
                xml.FORM_TYPE claimed: "201"
                # xml.THRDPRTY_EMAIL_ADR
                # xml.EFIN_ID
                # xml.PP_PH_NMBR
                xml.IAT_IND claimed: 2
                # xml.ORIG_SBMSN_ID
                if @submission.data_source.spouse.present? && @submission.data_source.spouse.birth_date.present?
                  xml.SP_DOB_DT claimed: @submission.data_source.spouse.birth_date.strftime("%Y-%m-%d")
                end
                # xml.FREE_FIL_IND
                # xml.PR_SSN_VALID_IND
                # xml.SP_SSN_VALID_IND
                xml.BNK_ACCT_ACH_IND claimed: 2 #only personal banking accounts supported not business
                if @submission.data_source.calculated_refund_or_owed_amount.positive?
                  xml.PAPER_CHK_RFND_IND claimed: @submission.data_source.payment_or_deposit_type == "direct_deposit" ? 2 : 1
                  xml.DIR_DEP_IND claimed: @submission.data_source.payment_or_deposit_type == "direct_deposit" ? 1 : 2
                else
                  xml.PAPER_CHK_RFND_IND claimed: 2
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
