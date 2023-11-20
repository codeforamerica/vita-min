module SubmissionBuilder
  module Ty2022
    module States
      module Az
        module Documents
          class FinancialTransaction < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("efile:FinancialTransaction") do |xml|

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
