module SubmissionBuilder
  module Ty2024
    module States
      module Nc
        module Documents
          class D400ScheduleS < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            FILING_STATUS_OPTIONS = {
              head_of_household: 'HOH',
              married_filing_jointly: 'MFJ',
              married_filing_separately: 'MFS',
              qualifying_widow: 'QW',
              single: "Single",
            }.freeze

            STANDARD_DEDUCTIONS = {
              head_of_household: 19125,
              married_filing_jointly: 25500,
              married_filing_separately: 12750,
              qualifying_widow: 25500,
              single: 12750,
            }.freeze

            def document
              build_xml_doc("FormNCD400ScheduleS") do |xml|
                xml.DedFedAGI do
                  add_non_zero_value(xml, :ExmptIncFedRecInd, :NCD400_LINE_27)
                end
              end
            end

            private

            def filing_status
              FILING_STATUS_OPTIONS[@submission.data_source.filing_status]
            end

            def standard_deduction
              STANDARD_DEDUCTIONS[@submission.data_source.filing_status]
            end

            def calculated_fields
              @calculated_fields ||= @submission.data_source.tax_calculator.calculate
            end
          end
        end
      end
    end
  end
end
