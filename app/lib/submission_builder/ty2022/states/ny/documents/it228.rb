# frozen_string_literal: true

module SubmissionBuilder
  module Ty2022
    module States
      module Ny
        module Documents
          class It228  < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("IT228") do |xml|
              end
            end
          end
        end
      end
    end
  end
end
