# frozen_string_literal: true
module SubmissionBuilder
  module Ty2024
    module States
      module Nc
        class NcReturnXml < SubmissionBuilder::StateReturn
          private

          def build_xml_doc_tag
            "efile:ReturnState"
          end

          def attached_documents_parent_tag
            "ReturnDataState"
          end

          def state_schema_version
            "NCIndividual2023v1.0"
          end

          def schema_file
            SchemaFileLoader.load_file("us_states", "unpacked", "NCIndividual2023v1.0", "NCIndividual", "IndividualReturnNCD400.xsd")
          end

          def supported_documents
            supported_docs = [
              {
                xml: SubmissionBuilder::Ty2024::States::Nc::Documents::D400,
                pdf: PdfFiller::NcD400Pdf,
                include: true
              },
            ]

            supported_docs += combined_w2s

            supported_docs
          end
        end
      end
    end
  end
end