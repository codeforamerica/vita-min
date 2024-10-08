# frozen_string_literal: true

module SubmissionBuilder
  module Ty2024
    module States
      module Id
        module Documents
          class Id40 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            FILING_STATUS_OPTIONS = {
              head_of_household: 'HOH',
              married_filing_jointly: 'JOINT',
              married_filing_separately: 'SEPART',
              qualifying_widow: 'QWID',
              single: "SINGLE",
            }.freeze


            def document
              build_xml_doc("Form40") do |xml|
                xml.FilingStatus filing_status
              end
            end

            private

            def filing_status
              FILING_STATUS_OPTIONS[@submission.data_source.filing_status]
            end
          end
        end
      end
    end
  end
end