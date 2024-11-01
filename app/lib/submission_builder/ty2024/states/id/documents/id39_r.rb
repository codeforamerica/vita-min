module SubmissionBuilder
  module Ty2024
    module States
      module Id
        module Documents
          class Id39R < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("Form39R") do |xml|
                xml.IncomeUSObligations calculated_fields.fetch(:ID39R_B_LINE_3)
                xml.HealthInsurancePaid calculated_fields.fetch(:ID39R_B_LINE_18)
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