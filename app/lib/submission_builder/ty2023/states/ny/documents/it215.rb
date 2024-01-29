module SubmissionBuilder
  module Ty2023
    module States
      module Ny
        module Documents
          class It215 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("IT215") do |xml|
                # If we got this far these values are known
                xml.E_FED_EITC_IND claimed: 1
                xml.E_INV_INC_IND claimed: 2

                xml.E_FED_FS_REQ_IND claimed: calculated_fields.fetch("IT215_LINE_3") ? 1 : 2
                xml.E_CHLD_CLM_IND claimed: calculated_fields.fetch("IT215_LINE_4") ? 1 : 2
                xml.E_IRS_FED_EITC_IND claimed: calculated_fields.fetch("IT215_LINE_5") ? 1 : 2
                add_non_zero_claimed_value(xml, :E_FED_WG_AMT, :IT215_LINE_6)
                add_non_zero_claimed_value(xml, :E_FED_FEDAGI_AMT, :IT215_LINE_9)
                add_non_zero_claimed_value(xml, :E_FED_EITC_CR_AMT, :IT215_LINE_10)
                add_non_zero_claimed_value(xml, :E_TNTV_EITC_CR_AMT, :IT215_LINE_12)
                add_non_zero_claimed_value(xml, :E_TX_B4CR_AMT, :IT215_LINE_13)
                add_non_zero_claimed_value(xml, :E_HH_CR_AMT, :IT215_LINE_14)
                add_non_zero_claimed_value(xml, :E_EITC_LMT_AMT, :IT215_LINE_15)
                add_non_zero_claimed_value(xml, :E_EITC_CR_AMT, :IT215_LINE_16)
                add_non_zero_claimed_value(xml, :E_NYC_EITC_CR_AMT, :IT215_LINE_27)
                add_non_zero_claimed_value(xml, :E_TX_AMT, :IT215_WK_B_LINE_1)
                add_non_zero_claimed_value(xml, :E_RSDT_CR_AMT, :IT215_WK_B_LINE_2)
                add_non_zero_claimed_value(xml, :E_ACM_DIST_AMT, :IT215_WK_B_LINE_3)
                add_non_zero_claimed_value(xml, :E_TOT_OTHCR_AMT, :IT215_WK_B_LINE_4)
                add_non_zero_claimed_value(xml, :E_NET_TX_AMT, :IT215_WK_B_LINE_5)
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
