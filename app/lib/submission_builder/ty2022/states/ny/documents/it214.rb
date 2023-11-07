module SubmissionBuilder
  module Ty2022
    module States
      module Ny
        module Documents
          class It214 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("IT214") do |xml|
                xml.PR_DOB_DT claimed: @submission.data_source.primary.birth_date.strftime("%Y-%m-%d")
                xml.R_RSDT_IND claimed: calculated_fields.fetch('IT214_LINE_1')
                xml.R_OCCPY_RSDT_IND claimed: calculated_fields.fetch('IT214_LINE_2')
                xml.R_RL_PROP_VL_IND claimed: calculated_fields.fetch('IT214_LINE_3')
                xml.R_DEPDT_IND claimed: calculated_fields.fetch('IT214_LINE_4')
                xml.R_RSDT_EXMPT_IND claimed: calculated_fields.fetch('IT214_LINE_5')
                xml.R_NRS_HOME_IND claimed: calculated_fields.fetch('IT214_LINE_6')
                xml.R_FEDAGI_AMT claimed: calculated_fields.fetch('IT214_LINE_9')
                xml.R_NYS_ADD_AMT claimed: calculated_fields.fetch('IT214_LINE_10')
                xml.R_SSINC_AMT claimed: calculated_fields.fetch('IT214_LINE_11')
                xml.R_SPLM_INC_AMT claimed: calculated_fields.fetch('IT214_LINE_12')
                xml.R_PNSN_AMT claimed: calculated_fields.fetch('IT214_LINE_13')
                xml.R_PUB_RELIEF_AMT claimed: calculated_fields.fetch('IT214_LINE_14')
                xml.R_OTHINC_AMT claimed: calculated_fields.fetch('IT214_LINE_15')
                xml.R_GRSS_INC_R_AMT claimed: calculated_fields.fetch('IT214_LINE_16')
                xml.R_GRSS_INC_PCT claimed: calculated_fields.fetch('IT214_LINE_17')
                xml.R_GRSS_AVL_AMT claimed: calculated_fields.fetch('IT214_LINE_18')
                if @submission.data_source.household_rent_own_rent?
                  xml.R_RENT_PD_AMT claimed: calculated_fields.fetch('IT214_LINE_19')
                  xml.R_ADJ_AMT claimed: calculated_fields.fetch('IT214_LINE_20')
                  xml.R_ADJ_RENT_AMT claimed: calculated_fields.fetch('IT214_LINE_21')
                  xml.R_RENT_TX_AMT claimed: calculated_fields.fetch('IT214_LINE_22')
                end
                if @submission.data_source.household_rent_own_own?
                  xml.R_RL_PROP_TXPD_AMT claimed: calculated_fields.fetch('IT214_LINE_23')
                  xml.R_ASMT_AMT claimed: calculated_fields.fetch('IT214_LINE_24')
                  xml.R_B4_EXMPT_AMT claimed: calculated_fields.fetch('IT214_LINE_25')
                  xml.R_HOME_RPTX_AMT claimed: calculated_fields.fetch('IT214_LINE_27')
                  xml.R_RL_PROP_TX_AMT claimed: calculated_fields.fetch('IT214_LINE_28')
                end
                xml.R_GRSS_AVL_AMT claimed: calculated_fields.fetch('IT214_LINE_29')
                xml.R_TNTV_RL_CR_AMT claimed: calculated_fields.fetch('IT214_LINE_30')
                xml.R_TX_AVL_CR_AMT claimed: calculated_fields.fetch('IT214_LINE_31')
                xml.R_CR_LMT_AMT claimed: calculated_fields.fetch('IT214_LINE_32')
                xml.R_RL_PROP_CR_AMT claimed: calculated_fields.fetch('IT214_LINE_33')
                # TODO: signature stuff is mostly here to make the xml valid, revisit later
                xml.PR_SGN_IND claimed: 1
                xml.SP_SGN_IND claimed: 1
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
