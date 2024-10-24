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
                  child_dependent_care.FederalAdjustedGrossIncome calculated_fields.fetch(:MD502_LINE_1)
                  child_dependent_care.FederalChildCareCredit calculated_fields.fetch(:MD502CR_PART_B_LINE_2)
                  child_dependent_care.DecimalAmount calculated_fields.fetch(:MD502CR_PART_B_LINE_3)
                  child_dependent_care.Credit calculated_fields.fetch(:MD502CR_PART_B_LINE_4)
                end
                xml.Senior do |senior|
                  senior.Credit calculated_fields.fetch(:MD502CR_PART_M_LINE_1)
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
