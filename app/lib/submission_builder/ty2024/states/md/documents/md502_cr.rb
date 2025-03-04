# frozen_string_literal: true

module SubmissionBuilder
  module Ty2024
    module States
      module Md
        module Documents
          class Md502Cr < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("Form502CR", documentId: "Form502CR") do |xml|
                xml.ChildAndDependentCare do |child_dependent_care|
                  add_non_zero_value(child_dependent_care, :FederalAdjustedGrossIncome, :MD502_LINE_1)
                  add_non_zero_value(child_dependent_care, :FederalChildCareCredit, :MD502CR_PART_B_LINE_2)
                  add_non_zero_float_value(child_dependent_care, :DecimalAmount, :MD502CR_PART_B_LINE_3)
                  add_non_zero_value(child_dependent_care, :Credit, :MD502CR_PART_B_LINE_4)
                end
                xml.Senior do |senior|
                  add_non_zero_value(senior, :Credit, :MD502CR_PART_M_LINE_1)
                end
                xml.Summary do
                  add_non_zero_value(xml, :ChildAndDependentCareCr, :MD502CR_PART_AA_LINE_2)
                  add_non_zero_value(xml, :SeniorCr, :MD502CR_PART_AA_LINE_13)
                  add_non_zero_value(xml, :TotalCredits, :MD502CR_PART_AA_LINE_14)
                end
                xml.Refundable do
                  add_non_zero_value(xml, :ChildAndDependentCareCr, :MD502CR_PART_CC_LINE_7)
                  add_non_zero_value(xml, :MDChildTaxCr, :MD502CR_PART_CC_LINE_8)
                  add_non_zero_value(xml, :TotalCredits, :MD502CR_PART_CC_LINE_10)
                end
              end
            end

            private

            def intake
              @submission.data_source
            end

            def calculated_fields
              @md502_cr_fields ||= intake.tax_calculator.calculate
            end
          end
        end
      end
    end
  end
end
