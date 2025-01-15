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
                  add_nc_amount_nn_value(xml, :USInterestInc, :NCD400_S_LINE_18)
                  add_nc_amount_nn_value(xml, :TaxPortSSRRB, :NCD400_S_LINE_19)
                  add_nc_amount_nn_value(xml, :ExmptIncFedRecInd, :NCD400_S_LINE_27)
                  add_nc_amount_nn_value(xml, :TotDedFromFAGI, :NCD400_S_LINE_41)
                end
              end
            end

            private

            def calculated_fields
              @calculated_fields ||= @submission.data_source.tax_calculator.calculate
            end

            def add_nc_amount_nn_value(xml, elem_name, line)
              # validates based on NCUSAmountNNType
              value = calculated_fields.fetch(line)&.round
              if value&.positive? && value.to_s.size <= 12
                xml.send(elem_name, value)
              end
            end
          end
        end
      end
    end
  end
end
