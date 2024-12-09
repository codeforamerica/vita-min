# frozen_string_literal: true

module SubmissionBuilder
  module Ty2024
    module States
      module Nj
        module Documents
          class ScheduleNjHcc < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def schema_file
              SchemaFileLoader.load_file("us_states", "unpacked", "NJIndividual2024V0.1", "NJCommon", "SchNJHCC.xsd")
            end

            def document

              build_xml_doc("SchNJHCC") do |xml|
                xml.HealthCovAllYear 'X'
              end
            end
          end
        end
      end
    end
  end
end