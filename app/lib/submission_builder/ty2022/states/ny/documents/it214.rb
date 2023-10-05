module SubmissionBuilder
  module Ty2022
    module States
      module Ny
        module Documents
          class It214 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("IT214") do |xml|
                xml.PR_DOB_DT claimed: @submission.data_source.primary.birth_date.strftime("%Y-%m-%d")
                xml.R_RSDT_IND claimed: 1
                xml.R_OCCPY_RSDT_IND claimed: 1
                xml.R_DEPDT_IND claimed: 2
                xml.R_RSDT_EXMPT_IND claimed: 2
                xml.R_NRS_HOME_IND claimed: 2
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
