module SubmissionBuilder
  module Ty2022
    module States
      module Ny
        module Documents
          class It213 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("IT213") do |xml|
                if @submission.data_source.form_213_present?
                  xml.ESC_RSDT_IND claimed: calculated_fields.fetch(:IT213_LINE_1) if calculated_fields.fetch(:IT213_LINE_1).present?
                  xml.ESC_FED_CR_IND claimed: calculated_fields.fetch(:IT213_LINE_2) if calculated_fields.fetch(:IT213_LINE_2).present?
                  xml.ESC_FAGI_LMT_IND claimed: calculated_fields.fetch(:IT213_LINE_3) if calculated_fields.fetch(:IT213_LINE_3).present?
                  if calculated_fields.fetch(:IT213_LINE_2) == 1 || calculated_fields.fetch(:IT213_LINE_3) == 1
                    add_non_zero_claimed_value(xml, :ESC_FED_CHLD_NMBR, :IT213_LINE_4)
                    add_non_zero_claimed_value(xml, :ESC_SSN_CHLD_NMBR, :IT213_LINE_5)
                    if calculated_fields.fetch(:IT213_LINE_2) == 1
                      add_non_zero_claimed_value(xml, :ESC_FED_CR_AMT, :IT213_LINE_6)
                      add_non_zero_claimed_value(xml, :ESC_FED_ADDL_AMT, :IT213_LINE_7)
                      add_non_zero_claimed_value(xml, :ESC_FED_TOT_AMT, :IT213_LINE_8)
                    end
                    add_non_zero_claimed_value(xml, :ESC_LMT_1_AMT, :IT213_LINE_9)
                    if calculated_fields.fetch(:IT213_LINE_3) == 1
                      add_non_zero_claimed_value(xml, :ESC_TOT_CHLD_NMBR, :IT213_LINE_12)
                      add_non_zero_claimed_value(xml, :ESC_LMT_2_AMT, :IT213_LINE_13)
                    end
                    add_non_zero_claimed_value(xml, :ESC_CHLD_CR_AMT, :IT213_LINE_14)
                    add_non_zero_claimed_value(xml, :ESC_FY_SP_SHR_AMT, :IT213_LINE_15)
                    add_non_zero_claimed_value(xml, :ESC_PY_SP_SHR_AMT, :IT213_LINE_16)
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
