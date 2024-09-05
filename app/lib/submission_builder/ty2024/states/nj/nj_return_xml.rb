# frozen_string_literal: true

module SubmissionBuilder
  module Ty2024
    module States
      module Nj
        class NjReturnXml < SubmissionBuilder::StateReturn

          private

          def attached_documents_parent_tag
            # Line 29 in ReturnDataNj1040.xsd
            'ReturnDataState'
          end

          def build_xml_doc_tag
            # Line 17 in IndividualReturnNj1040.xsd
            "ReturnState"
          end

          def state_schema_version
            "NJIndividual2023V0.4"
          end

          def documents_wrapper
            nil
          end

          def schema_file
            SchemaFileLoader.load_file("us_states", "unpacked", "NJIndividual2023V0.4", "NJIndividual", "IndividualReturnNJ1040.xsd")
          end

          def supported_documents
            supported_docs = [
              {
                xml: SubmissionBuilder::Ty2024::States::Nj::Documents::Nj1040,
                # pdf: PdfFiller::Nj1040Pdf, TODO
                pdf: nil,
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