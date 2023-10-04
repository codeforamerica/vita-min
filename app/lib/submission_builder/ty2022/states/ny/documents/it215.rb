module SubmissionBuilder
  module Ty2022
    module States
      module Ny
        module Documents
          class It215 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("IT215") do |xml|
                xml.E_FED_EITC_IND claimed: calculated_fields.fetch("IT215_LINE_1") ? 1 : 2
                xml.E_FED_ADJ_IND claimed: calculated_fields.fetch("IT215_LINE_1A") ? 1 : 2
                xml.E_INV_INC_IND claimed: calculated_fields.fetch("IT215_LINE_2") ? 1 : 2
                xml.E_CHLD_CLM_IND claimed: calculated_fields.fetch("IT215_LINE_4") ? 1 : 2
                # TODO need to fill in dependents to XML
                xml.E_IRS_FED_EITC_IND claimed: calculated_fields.fetch("IT215_LINE_5") ? 1 : 2
                xml.E_FED_WG_AMT claimed: calculated_fields.fetch("IT215_LINE_6")
                xml.E_FED_FEDAGI_AMT claimed: calculated_fields.fetch("IT215_LINE_9")
                xml.E_TNTV_EITC_CR_AMT claimed: calculated_fields.fetch("IT215_LINE_12")
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
