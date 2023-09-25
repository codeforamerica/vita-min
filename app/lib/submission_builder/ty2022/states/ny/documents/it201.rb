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
                xml.NYC_LVNG_QTR_IND claimed: NYC_RES[@submission.data_source.nyc_resident_e.to_sym]
                # TODO: DAYS_NYC_NMBR are we only taking full-year nyc residents?
                xml.WG_AMT claimed: calculated_fields.fetch('AMT_1')
                xml.INT_AMT claimed: calculated_fields.fetch('AMT_2')
                xml.TX_UNEMP_AMT claimed: calculated_fields.fetch('AMT_14')
                xml.SSINC_AMT claimed: calculated_fields.fetch('AMT_15')
                xml.FEDAGI_B4_ADJ_AMT claimed: calculated_fields.fetch('AMT_17')
                xml.FEDADJ_AMT claimed: calculated_fields.fetch('AMT_18')
                xml.FEDAGI_AMT claimed: calculated_fields.fetch('AMT_19')
                xml.A_PBEMP_AMT claimed: calculated_fields.fetch('AMT_21')
                xml.A_OTH_AMT claimed: calculated_fields.fetch('AMT_23') # TODO: might be a bit more to it than this
                xml.A_SUBTL_AMT claimed: calculated_fields.fetch('AMT_24')
                xml.S_TXBL_SS_AMT claimed: calculated_fields.fetch('AMT_27')
                xml.S_SUBTL_AMT claimed: calculated_fields.fetch('AMT_32')
                xml.NYSAGI_AMT claimed: calculated_fields.fetch('AMT_33')
                xml.STD_ITZ_IND claimed: 1
                xml.DED_AMT claimed: calculated_fields.fetch('AMT_34')
                xml.INC_B4_EXMPT_AMT claimed: calculated_fields.fetch('AMT_35')
                xml.EXMPT_NMBR claimed: calculated_fields.fetch('AMT_36')
                xml.TXBL_INC_AMT claimed: calculated_fields.fetch('AMT_37')
                xml.TX_B4CR_AMT claimed: calculated_fields.fetch('AMT_39')
                xml.HH_CR_AMT claimed: calculated_fields.fetch('AMT_40')
                xml.TOT_NRFNDCR_AMT claimed: calculated_fields.fetch('AMT_43')
                xml.TX_AFT_NRFNDCR_AMT claimed: calculated_fields.fetch('AMT_44')
                xml.TOT_TX_AMT claimed: calculated_fields.fetch('AMT_46')
                xml.NYC_TXBL_INC_AMT claimed: calculated_fields.fetch('AMT_47')
                xml.NYC_TX_B4CR_AMT claimed: calculated_fields.fetch('AMT_47A')
                xml.NYC_HH_CR_AMT claimed: calculated_fields.fetch('AMT_48')
                xml.NYC_TX_AFT_HH_AMT claimed: calculated_fields.fetch('AMT_49')
                xml.NYC_TOT_TX_AMT claimed: calculated_fields.fetch('AMT_52')
                xml.NYC_TAX_AFT_CR_AMT claimed: calculated_fields.fetch('AMT_54')
                xml.NYC_YNK_NET_TX_AMT claimed: calculated_fields.fetch('AMT_58')
                xml.SALE_USE_AMT claimed: calculated_fields.fetch('AMT_59')
                xml.TX_GFT_AMT claimed: calculated_fields.fetch('AMT_61')
                xml.ESC_CHLD_CR_AMT claimed: calculated_fields.fetch('AMT_63')
                xml.EITC_CR_AMT claimed: calculated_fields.fetch('AMT_65')
                xml.RL_PROP_CR_AMT claimed: calculated_fields.fetch('AMT_67')
                xml.NYC_STAR_CR_AMT claimed: calculated_fields.fetch('AMT_69')
                xml.NYC_STAR_REDCR_AMT claimed: calculated_fields.fetch('AMT_69A')
                xml.NYC_EITC_CR_AMT claimed: calculated_fields.fetch('AMT_70')
                xml.TOT_WTHLD_AMT claimed: calculated_fields.fetch('AMT_72')
                xml.TOT_NYC_WTHLD_AMT claimed: calculated_fields.fetch('AMT_73')
                xml.TOT_PAY_AMT claimed: calculated_fields.fetch('AMT_76')
                xml.OVR_PAID_AMT claimed: calculated_fields.fetch('AMT_77')
                xml.RFND_B4_EDU_AMT claimed: calculated_fields.fetch('AMT_78')
                xml.RFND_AMT claimed: calculated_fields.fetch('AMT_78B')

                # TODO: seems like most of the money transfer stuff goes in the return header instead
                # xml.BAL_DUE_AMT claimed: calculated_fields.fetch('AMT_80')
                # xml.RFND_OWE_IND claimed: TODO
                # xml.ACCT_TYPE_CD claimed: TODO
                # xml.ABA_NMBR claimed: @submission.data_source.routing_number
                # xml.BANK_ACCT_NMBR claimed: @submission.data_source.account_number
                # xml.ELC_AUTH_EFCTV_DT claimed: @submission.data_source.date_electronic_withdrawal

                # xml.PYMT_AMT claimed: TODO
                xml.PR_SGN_IND claimed: 1

                # TODO: this one is not a 'claimed' style field apparently
                # xml.IT201FEDADJID claimed: @submission.data_source.total_fed_adjustments_identify
              end
            end

            private

            def calculated_fields
              @it201_fields ||=
                begin
                  it201 = Efile::Ny::It201.new(
                    year: 2022,
                    filing_status: @submission.data_source.filing_status.to_sym,
                    claimed_as_dependent: false,
                    dependent_count: 0,
                    lines: {
                      AMT_1: @submission.data_source.fed_wages,
                      AMT_2: @submission.data_source.fed_taxable_income,
                      AMT_14: @submission.data_source.fed_unemployment,
                      AMT_15: @submission.data_source.fed_taxable_ssb,
                      AMT_18: @submission.data_source.total_fed_adjustments,
                      AMT_21: 0, # TODO: this will be a certain subset of the w2 income
                      AMT_23: @submission.data_source.ny_other_additions.presence || 0,
                      AMT_27: @submission.data_source.fed_taxable_ssb,
                      AMT_59: @submission.data_source.sales_use_tax || 0,
                      AMT_72: @submission.data_source.total_state_tax_withheld,
                      # AMT_73: @submission.data_source.total_city_tax_withheld, TODO
                    },
                    it213: Efile::Ny::It213.new,
                    it214: Efile::Ny::It214.new,
                    it215: Efile::Ny::It215.new,
                    it227: Efile::Ny::It227.new
                  )
                  it201.calculate
                end
            end
          end
        end
      end
    end
  end
end
