# frozen_string_literal: true

module SubmissionBuilder
  module Ty2024
    module States
      module Md
        module Documents
          class Md502b < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("Form502B") do |xml|
                xml.Dependents do
                  xml.CountRegular calculated_fields.fetch(:MD502B_LINE_1)
                  xml.CountOver65 calculated_fields.fetch(:MD502B_LINE_2)
                  xml.Count calculated_fields.fetch(:MD502B_LINE_3)

                  intake.dependents.each do |dependent|
                    xml.Dependent do
                      xml.Name do
                        xml.FirstName sanitize_for_xml(dependent.first_name, 16)
                        xml.MiddleInitial sanitize_for_xml(dependent.middle_initial, 1) if dependent.middle_initial.present?
                        xml.LastName sanitize_for_xml(dependent.last_name, 32)
                      end
                      xml.SSN dependent.ssn
                      xml.RelationToTaxpayer dependent.relationship_label
                      xml.ClaimedAsDependent "X"
                      xml.Over65 "X" if dependent.senior?
                      xml.DependentDOB dependent.dob.strftime("%Y-%m-%d")
                    end
                  end
                end
              end
            end

            private

            def intake
              @submission.data_source
            end

            def calculated_fields
              @calculated_fields ||= intake.tax_calculator.calculate
            end
          end
        end
      end
    end
  end
end