module SubmissionBuilder
  module Ty2023
    module States
      module Ny
        module Documents
          class It214 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("IT214") do |xml|
                xml.PR_DOB_DT claimed: @submission.data_source.primary.birth_date.strftime("%Y-%m-%d") if @submission.data_source.primary.birth_date.present?
                add_non_zero_claimed_value(xml, :R_RSDT_IND, :IT214_LINE_1)
                add_non_zero_claimed_value(xml, :R_OCCPY_RSDT_IND, :IT214_LINE_2)
                add_non_zero_claimed_value(xml, :R_RL_PROP_VL_IND, :IT214_LINE_3)
                add_non_zero_claimed_value(xml, :R_DEPDT_IND, :IT214_LINE_4)
                add_non_zero_claimed_value(xml, :R_RSDT_EXMPT_IND, :IT214_LINE_5)
                add_non_zero_claimed_value(xml, :R_NRS_HOME_IND, :IT214_LINE_6)
                add_non_zero_claimed_value(xml, :R_FEDAGI_AMT, :IT214_LINE_9)
                add_non_zero_claimed_value(xml, :R_NYS_ADD_AMT, :IT214_LINE_10)
                add_non_zero_claimed_value(xml, :R_SSINC_AMT, :IT214_LINE_11)
                add_non_zero_claimed_value(xml, :R_SPLM_INC_AMT, :IT214_LINE_12)
                add_non_zero_claimed_value(xml, :R_PNSN_AMT, :IT214_LINE_13)
                add_non_zero_claimed_value(xml, :R_PUB_RELIEF_AMT, :IT214_LINE_14)
                add_non_zero_claimed_value(xml, :R_OTHINC_AMT, :IT214_LINE_15)
                add_non_zero_claimed_value(xml, :R_GRSS_INC_R_AMT, :IT214_LINE_16)
                add_non_zero_claimed_value(xml, :R_GRSS_INC_PCT, :IT214_LINE_17)
                add_non_zero_claimed_value(xml, :R_GRSS_AVL_AMT, :IT214_LINE_18)
                if @submission.data_source.household_rent_own_rent?
                  add_non_zero_claimed_value(xml, :R_RENT_PD_AMT, :IT214_LINE_19)
                  add_non_zero_claimed_value(xml, :R_ADJ_AMT, :IT214_LINE_20)
                  add_non_zero_claimed_value(xml, :R_ADJ_RENT_AMT, :IT214_LINE_21)
                  add_non_zero_claimed_value(xml, :R_RENT_TX_AMT, :IT214_LINE_22)
                end
                if @submission.data_source.household_rent_own_own?
                  add_non_zero_claimed_value(xml, :R_RL_PROP_TXPD_AMT, :IT214_LINE_23)
                  add_non_zero_claimed_value(xml, :R_ASMT_AMT, :IT214_LINE_24)
                  add_non_zero_claimed_value(xml, :R_B4_EXMPT_AMT, :IT214_LINE_25)
                  add_non_zero_claimed_value(xml, :R_HOME_RPTX_AMT, :IT214_LINE_27)
                end
                add_non_zero_claimed_value(xml, :R_RL_PROP_TX_AMT, :IT214_LINE_28)
                add_non_zero_claimed_value(xml, :R_GRSS_AVL_AMT, :IT214_LINE_29)
                add_non_zero_claimed_value(xml, :R_TNTV_RL_CR_AMT, :IT214_LINE_30)
                add_non_zero_claimed_value(xml, :R_TX_AVL_CR_AMT, :IT214_LINE_31)
                add_non_zero_claimed_value(xml, :R_CR_LMT_AMT, :IT214_LINE_32)
                add_non_zero_claimed_value(xml, :R_RL_PROP_CR_AMT, :IT214_LINE_33)
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
