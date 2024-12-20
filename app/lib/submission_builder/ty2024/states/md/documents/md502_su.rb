# frozen_string_literal: true

module SubmissionBuilder
  module Ty2024
    module States
      module Md
        module Documents
          class Md502Su < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("Form502SU", documentId: "Form502SU") do |xml|
                xml.Subtractions do |subtractions|
                  if calculated_fields.fetch(:MD502_SU_LINE_AB).positive?
                    subtractions.OtherDetail do |other_detail|
                      other_detail.Code "AB"
                      other_detail.Amount calculated_fields.fetch(:MD502_SU_LINE_AB)
                    end
                  end
                  subtractions.Total calculated_fields.fetch(:MD502_SU_LINE_1)
                end
              end
            end

            private

            def intake
              @submission.data_source
            end

            def calculated_fields
              @md502_su_fields ||= intake.tax_calculator.calculate
            end
          end
        end
      end
    end
  end
end
