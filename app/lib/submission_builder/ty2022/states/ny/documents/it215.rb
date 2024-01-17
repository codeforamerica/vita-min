module SubmissionBuilder
  module Ty2022
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
                xml.E_FED_WG_AMT claimed: calculated_fields.fetch("IT215_LINE_6")
                xml.E_FED_FEDAGI_AMT claimed: calculated_fields.fetch("IT215_LINE_9")
                if calculated_fields.fetch("IT215_LINE_10").present?
                  xml.E_FED_EITC_CR_AMT claimed: calculated_fields.fetch("IT215_LINE_10")
                end
                xml.E_TNTV_EITC_CR_AMT claimed: calculated_fields.fetch("IT215_LINE_12")
                xml.E_TX_B4CR_AMT claimed: calculated_fields.fetch("IT215_LINE_13")
                xml.E_HH_CR_AMT claimed: calculated_fields.fetch("IT215_LINE_14")
                xml.E_EITC_LMT_AMT claimed: calculated_fields.fetch("IT215_LINE_15")
                xml.E_EITC_CR_AMT claimed: calculated_fields.fetch("IT215_LINE_16")
                if calculated_fields["IT215_LINE_27"]
                  xml.E_NYC_EITC_CR_AMT claimed: calculated_fields.fetch("IT215_LINE_27")
                end
                xml.E_TX_AMT claimed: calculated_fields.fetch("IT215_WK_B_LINE_1")
                xml.E_RSDT_CR_AMT claimed: calculated_fields.fetch("IT215_WK_B_LINE_2")
                xml.E_ACM_DIST_AMT claimed: calculated_fields.fetch("IT215_WK_B_LINE_3")
                xml.E_TOT_OTHCR_AMT claimed: calculated_fields.fetch("IT215_WK_B_LINE_4")
                xml.E_NET_TX_AMT claimed: calculated_fields.fetch("IT215_WK_B_LINE_5")
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
