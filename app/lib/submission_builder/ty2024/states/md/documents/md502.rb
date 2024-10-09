# frozen_string_literal: true

module SubmissionBuilder
  module Ty2024
    module States
      module Md
        module Documents
          class Md502 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("Form502") do |xml|
                xml.ResidencyStatusPrimary true
                if has_exemptions
                  xml.Exemptions do
                    if has_dependent_exemption
                      xml.Dependents do
                        xml.Count calculated_fields.fetch(:MD502_DEPENDENT_EXEMPTION_COUNT)
                        xml.Amount calculated_fields.fetch(:MD502_DEPENDENT_EXEMPTION_AMOUNT)
                      end
                    end
                  end
                end
                add_non_zero_value(xml, :ExemptionAmount, :MD502_EXEMPTION_AMOUNT)
              end
            end

            private

            def intake
              @submission.data_source
            end

            def calculated_fields
              @md502_fields ||= intake.tax_calculator.calculate
            end

            def has_dependent_exemption
              [
                :MD502_DEPENDENT_EXEMPTION_COUNT,
                :MD502_DEPENDENT_EXEMPTION_AMOUNT
              ].any? do |line|
                calculated_fields.fetch(line) > 0
              end
            end

            def has_exemptions
              has_dependent_exemption
            end
          end
        end
      end
    end
  end
end