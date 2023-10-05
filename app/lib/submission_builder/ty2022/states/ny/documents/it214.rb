module SubmissionBuilder
  module Ty2022
    module States
      module Ny
        module Documents
          class It214 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("IT214") do |xml|
                xml.E_FED_EITC_IND claimed: calculated_fields.fetch("IT215_LINE_1") ? 1 : 2

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
