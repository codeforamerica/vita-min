module SubmissionBuilder
  module Ty2024
    module States
      module Nc
        module Documents
          class D400ScheduleS < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("FormNCD400ScheduleS") do |xml|
                xml.DedFedAGI do
                  xml.USInterestInc calculated_fields.fetch(:NCD400_S_LINE_18)
                  xml.TaxPortSSRRB calculated_fields.fetch(:NCD400_S_LINE_19)
                  xml.ExmptIncFedRecInd calculated_fields.fetch(:NCD400_S_LINE_27)
                  xml.TotDedFromFAGI calculated_fields.fetch(:NCD400_S_LINE_41)
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
