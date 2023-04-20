module SubmissionBuilder
  module Ty2022
    module States
      module Ny
        module Documents
          class It201Att < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("IT201ATT") do |xml|
              end
            end
          end
        end
      end
    end
  end
end
