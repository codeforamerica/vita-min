module SubmissionBuilder
  module Ty2022
    module States
      module Ny
        module Documents
          class It213 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("IT213") do |xml|
                xml.ESC_RSDT_IND claimed: 1
                xml.ESC_FED_CR_IND claimed: 1
                xml.ESC_FAGI_LMT_IND claimed: calculated_fields.fetch(:IT213_LINE_3) ? 1 : 2
                xml.ESC_FED_CHLD_NMBR claimed: calculated_fields.fetch(:IT213_LINE_4)
                xml.ESC_SSN_CHLD_NMBR claimed: 0 # TODO: double check that people with children without SSN/ITIN are out of scope
                xml.ESC_FED_CR_AMT claimed: calculated_fields.fetch(:IT213_LINE_6)
                xml.ESC_FED_ADDL_AMT claimed: calculated_fields.fetch(:IT213_LINE_7)
                xml.ESC_FED_TOT_AMT claimed: calculated_fields.fetch(:IT213_LINE_8)
                xml.ESC_LMT_1_AMT claimed: calculated_fields.fetch(:IT213_LINE_13)
                if calculated_fields[:IT213_LINE_14]
                  xml.ESC_LMT_2_AMT claimed: calculated_fields.fetch(:IT213_LINE_15)
                end
                xml.ESC_CHLD_CR_AMT claimed: calculated_fields.fetch(:IT213_LINE_16)
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
