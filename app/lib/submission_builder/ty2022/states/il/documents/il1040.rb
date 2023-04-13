module SubmissionBuilder
  module Ty2022
    module States
      module Il
        module Documents
          class Il1040 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("FormIL1040") do |xml|
                xml.IL1040Shared do
                  xml.FilingStatus "1"
                  xml.TotalIncome 5000
                end
              end
            end
          end
        end
      end
    end
  end
end