# frozen_string_literal: true

module SubmissionBuilder
  module Ty2024
    module States
      module Id
        class IdReturnXml < SubmissionBuilder::StateReturn

          private

          def attached_documents_parent_tag
            "ReturnDataState"
          end

          def build_xml_doc_tag
            "ReturnState"
          end

          def state_schema_version
            ""
          end

          def documents_wrapper
            nil
          end

          def schema_file
            SchemaFileLoader.load_file("us_states", "unpacked", "ID.MeF2023V1.0", "IncomeTax", "Form40", "IdahoIndividualResidentReturn.xsd")
          end

          def supported_documents
            supported_docs = [
              {
                xml: SubmissionBuilder::Ty2024::States::Id::Documents::Id40,
                pdf: PdfFiller::Id40Pdf,
                include: true
              },
            ]
            
            supported_docs += form1099gs
            supported_docs
          end
        end
      end
    end
  end
end