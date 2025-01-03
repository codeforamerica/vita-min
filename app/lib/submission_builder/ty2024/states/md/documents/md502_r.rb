# frozen_string_literal: true

module SubmissionBuilder
  module Ty2024
    module States
      module Md
        module Documents
          class Md502R < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("Form502R", documentId: "Form502R") do |xml|
              end
            end

            private

            def intake
              @submission.data_source
            end

            def calculated_fields
              @md502_r_fields ||= intake.tax_calculator.calculate
            end
          end
        end
      end
    end
  end
end