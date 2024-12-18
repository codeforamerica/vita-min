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
                  add_non_zero_value(xml, :USInterestInc, :NCD400_S_LINE_18)
                  add_non_zero_value(xml, :TaxPortSSRRB, :NCD400_S_LINE_19)
                  add_non_zero_value(xml, :ExmptIncFedRecInd, :NCD400_S_LINE_27)
                  add_non_zero_value(xml, :TotDedFromFAGI, :NCD400_S_LINE_41)
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
