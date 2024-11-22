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
              {
                xml: SubmissionBuilder::Ty2024::States::Id::Documents::Id39R,
                pdf: PdfFiller::Id39rPdf,
                include: true
              },
            ]
            # For dependents 1-7: First 4 dependents listed on ID40, next 3 dependents are added to first ID39R form
            # For more than 7 dependents total (the State XML field can handle a max of 20): additional copies of ID Form 39R PDF is used to handle these cases
            @submission.data_source.dependents.drop(7).take(13).each_slice(3) do |dependents|
              supported_docs << {
                xml: nil,
                pdf: PdfFiller::Id39rAdditionalDependentsPdf,
                include: true,
                kwargs: { dependents: dependents }
              }
            end

            supported_docs
          end
        end
      end
    end
  end
end
