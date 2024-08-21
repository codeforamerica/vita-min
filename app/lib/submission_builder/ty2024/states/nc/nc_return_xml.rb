# frozen_string_literal: true
module SubmissionBuilder
  module Ty2024
    module States
      module Nc
        class NcReturnXml < SubmissionBuilder::StateReturn
          private

          def schema_file
            SchemaFileLoader.load_file("us_states", "unpacked", "NCIndividual2023v1.0", "NCIndividual", "IndividualReturnNCD400.xsd")
          end

          def documents_wrapper
            xml_doc = build_xml_doc("FormNCD400")
            xml_doc.at('*')
          end

          def supported_documents
            []
          end
        end
      end
    end
  end
end