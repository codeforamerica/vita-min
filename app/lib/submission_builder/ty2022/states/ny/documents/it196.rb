# frozen_string_literal: true

module SubmissionBuilder
  module Ty2022
    module States
      module Ny
        module Documents
          class It196 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("IT196") do |xml|
                xml.DED_FED_LMT_IND claimed: 1
                xml.TOT_FEDITZDED_AMT claimed: 0.0
                xml.NYS_ITZDED_AMT claimed: 0.0
              end
            end
          end
        end
      end
    end
  end
end
