# frozen_string_literal: true

module SubmissionBuilder
  module Ty2024
    module States
      module Id
        module Documents
          class Id40 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("Form40") do |xml|
                xml.ResidencyStatusPrimary true
              end
            end
          end
        end
      end
    end
  end
end