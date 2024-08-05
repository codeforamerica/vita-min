module SubmissionBuilder
  module Ty2022
    module States
      module Az
        module Documents
          class Az322 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("Form322") do |xml|

              end
            end
          end
        end
      end
    end
  end
end
