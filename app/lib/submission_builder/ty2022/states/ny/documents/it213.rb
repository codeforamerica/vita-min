module SubmissionBuilder
  module Ty2022
    module States
      module Ny
        module Documents
          class It213 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("IT213") do |xml|
                if @submission.data_source.eligibility_lived_in_state_yes?
                  xml.ESC_RSDT_IND claimed: calculated_fields.fetch(:IT213_LINE_1)
                  xml.ESC_FED_CR_IND claimed: calculated_fields.fetch(:IT213_LINE_2)
                  xml.ESC_FAGI_LMT_IND claimed: calculated_fields.fetch(:IT213_LINE_3)
                  if calculated_fields.fetch(:IT213_LINE_2) == 1 || calculated_fields.fetch(:IT213_LINE_3) == 1
                    xml.ESC_FED_CHLD_NMBR claimed: calculated_fields.fetch(:IT213_LINE_4)
                    xml.ESC_SSN_CHLD_NMBR claimed: calculated_fields.fetch(:IT213_LINE_5)
                    if calculated_fields.fetch(:IT213_LINE_2) == 1
                      xml.ESC_FED_CR_AMT claimed: calculated_fields.fetch(:IT213_LINE_6)
                      xml.ESC_FED_ADDL_AMT claimed: calculated_fields.fetch(:IT213_LINE_7)
                      xml.ESC_FED_TOT_AMT claimed: calculated_fields.fetch(:IT213_LINE_8)
                    end
                    xml.ESC_LMT_1_AMT claimed: calculated_fields.fetch(:IT213_LINE_9)
                    xml.ESC_TOT_CHLD_NMBR claimed: calculated_fields.fetch(:IT213_LINE_12)
                    xml.ESC_LMT_2_AMT claimed: calculated_fields.fetch(:IT213_LINE_13)
                    xml.ESC_CHLD_CR_AMT claimed: calculated_fields.fetch(:IT213_LINE_14)
                    xml.ESC_FY_SP_SHR_AMT claimed: calculated_fields.fetch(:IT213_LINE_15)
                    xml.ESC_PY_SP_SHR_AMT claimed: calculated_fields.fetch(:IT213_LINE_16)
                  end
                end
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
