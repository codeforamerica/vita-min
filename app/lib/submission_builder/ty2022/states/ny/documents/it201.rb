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
            CLAIMED_AS_DEP = {
              yes: 1,
              no: 2
            }
            NYC_RES = {
              yes: 1,
              no: 2
            }

            def document
              build_xml_doc("IT201") do |xml|
                xml.PR_DOB_DT claimed: @submission.data_source.primary.birth_date.strftime("%Y-%m-%d")
                xml.FS_CD claimed: FILING_STATUSES[@submission.data_source.filing_status.to_sym]
                xml.FED_ITZDED_IND claimed: 2
                xml.DEP_CLAIM_IND claimed: CLAIMED_AS_DEP[@submission.data_source.claimed_as_dep.to_sym]
                xml.NYC_LVNG_QTR_IND claimed: NYC_RES[@submission.data_source.nyc_full_year_resident.to_sym]
                # TODO: DAYS_NYC_NMBR are we only taking full-year nyc residents?
                xml.WG_AMT claimed: calculated_fields.fetch(:IT201_LINE_1)
                xml.INT_AMT claimed: calculated_fields.fetch(:IT201_LINE_2)
                xml.TX_UNEMP_AMT claimed: calculated_fields.fetch(:IT201_LINE_14)
                xml.SSINC_AMT claimed: calculated_fields.fetch(:IT201_LINE_15)
                xml.FEDAGI_B4_ADJ_AMT claimed: calculated_fields.fetch(:IT201_LINE_17)
                xml.FEDADJ_AMT claimed: calculated_fields.fetch(:IT201_LINE_18)
                xml.FEDAGI_AMT claimed: calculated_fields.fetch(:IT201_LINE_19)
                xml.A_PBEMP_AMT claimed: calculated_fields.fetch(:IT201_LINE_21)
                xml.A_OTH_AMT claimed: calculated_fields.fetch(:IT201_LINE_23) || 0 # TODO: might be a bit more to it than this
                xml.A_SUBTL_AMT claimed: calculated_fields.fetch(:IT201_LINE_24)
                xml.S_TXBL_SS_AMT claimed: calculated_fields.fetch(:IT201_LINE_27)
                xml.S_SUBTL_AMT claimed: calculated_fields.fetch(:IT201_LINE_32)
                xml.NYSAGI_AMT claimed: calculated_fields.fetch(:IT201_LINE_33)
                xml.STD_ITZ_IND claimed: 1
                xml.DED_AMT claimed: calculated_fields.fetch(:IT201_LINE_34)
                xml.INC_B4_EXMPT_AMT claimed: calculated_fields.fetch(:IT201_LINE_35)
                xml.EXMPT_NMBR claimed: calculated_fields.fetch(:IT201_LINE_36)
                xml.TXBL_INC_AMT claimed: calculated_fields.fetch(:IT201_LINE_37)
                xml.TX_B4CR_AMT claimed: calculated_fields.fetch(:IT201_LINE_39)
                xml.HH_CR_AMT claimed: calculated_fields.fetch(:IT201_LINE_40)
                xml.TOT_NRFNDCR_AMT claimed: calculated_fields.fetch(:IT201_LINE_43)
                xml.TX_AFT_NRFNDCR_AMT claimed: calculated_fields.fetch(:IT201_LINE_44)
                xml.TOT_TX_AMT claimed: calculated_fields.fetch(:IT201_LINE_46)
                xml.NYC_TXBL_INC_AMT claimed: calculated_fields.fetch(:IT201_LINE_47)
                xml.NYC_TX_B4CR_AMT claimed: calculated_fields.fetch(:IT201_LINE_47A)
                xml.NYC_HH_CR_AMT claimed: calculated_fields.fetch(:IT201_LINE_48)
                xml.NYC_TX_AFT_HH_AMT claimed: calculated_fields.fetch(:IT201_LINE_49)
                xml.NYC_TOT_TX_AMT claimed: calculated_fields.fetch(:IT201_LINE_52)
                xml.NYC_TAX_AFT_CR_AMT claimed: calculated_fields.fetch(:IT201_LINE_54)
                xml.NYC_YNK_NET_TX_AMT claimed: calculated_fields.fetch(:IT201_LINE_58)
                xml.SALE_USE_AMT claimed: calculated_fields.fetch(:IT201_LINE_59) || 0
                xml.TX_GFT_AMT claimed: calculated_fields.fetch(:IT201_LINE_61)
                xml.ESC_CHLD_CR_AMT claimed: calculated_fields.fetch(:IT201_LINE_63)
                xml.EITC_CR_AMT claimed: calculated_fields.fetch(:IT201_LINE_65)
                xml.RL_PROP_CR_AMT claimed: calculated_fields.fetch(:IT201_LINE_67)
                xml.NYC_STAR_CR_AMT claimed: calculated_fields.fetch(:IT201_LINE_69)
                xml.NYC_STAR_REDCR_AMT claimed: calculated_fields.fetch(:IT201_LINE_69A)
                xml.NYC_EITC_CR_AMT claimed: calculated_fields.fetch(:IT201_LINE_70)
                xml.TOT_WTHLD_AMT claimed: calculated_fields.fetch(:IT201_LINE_72)
                xml.TOT_NYC_WTHLD_AMT claimed: calculated_fields.fetch(:IT201_LINE_73)
                xml.TOT_PAY_AMT claimed: calculated_fields.fetch(:IT201_LINE_76)
                xml.OVR_PAID_AMT claimed: calculated_fields.fetch(:IT201_LINE_77)
                xml.RFND_B4_EDU_AMT claimed: calculated_fields.fetch(:IT201_LINE_78)
                xml.RFND_AMT claimed: calculated_fields.fetch(:IT201_LINE_78B)

                # TODO: seems like most of the money transfer stuff goes in the return header instead
                # xml.BAL_DUE_AMT claimed: calculated_fields.fetch(:IT201_LINE_80)
                # xml.RFND_OWE_IND claimed: TODO
                # xml.ACCT_TYPE_CD claimed: TODO
                # xml.ABA_NMBR claimed: @submission.data_source.routing_number
                # xml.BANK_ACCT_NMBR claimed: @submission.data_source.account_number
                # xml.ELC_AUTH_EFCTV_DT claimed: @submission.data_source.date_electronic_withdrawal

                # xml.PYMT_AMT claimed: TODO
                xml.PR_SGN_IND claimed: 1

                xml.IT201FEDADJID do
                  @submission.data_source.direct_file_data.fed_adjustments_claimed.each do |type, info|
                    xml.descAmt do
                      xml.DESCRIPTION claimed: info[:xml_label]
                      xml.AMOUNT claimed: info[:amount]
                    end
                  end
                end
              end
            end

            private

            def calculated_fields
              @it201_fields ||= @submission.data_source.tax_calculator.calculate
            end
          end
        end
      end
    end
  end
end
