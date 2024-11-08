# frozen_string_literal: true

module SubmissionBuilder
  module Ty2024
    module States
      module Nj
        class NjReturnXml < SubmissionBuilder::StateReturn

          def w2_class
            SubmissionBuilder::Ty2024::States::Nj::Documents::NjW2
          end

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
            "NJIndividual2024V0.1"
          end

          def documents_wrapper
            nil
          end

          def schema_file
            SchemaFileLoader.load_file("us_states", "unpacked", "NJIndividual2024V0.1", "NJIndividual", "IndividualReturnNJ1040.xsd")
          end

          def supported_documents
            supported_docs = [
              {
                xml: SubmissionBuilder::Ty2024::States::Nj::Documents::Nj1040,
                pdf: PdfFiller::Nj1040Pdf,
                include: true
              }
            ]

            supported_docs += combined_w2s
            supported_docs += nj_2450s
            supported_docs
          end

          def nj_2450s
            docs = []

            if calculator.line_59_primary.positive? || calculator.line_61_primary.positive?
              docs << {
                xml: SubmissionBuilder::Ty2024::States::Nj::Documents::Nj2450,
                pdf: PdfFiller::Nj2450Pdf,
                include: true,
                kwargs: { person: intake.primary }
              }
            end

            if calculator.line_59_spouse.positive? || calculator.line_61_spouse.positive?
              docs << {
                xml: SubmissionBuilder::Ty2024::States::Nj::Documents::Nj2450,
                pdf: PdfFiller::Nj2450Pdf,
                include: true,
                kwargs: { person: intake.spouse }
              }
            end

            docs
          end          

          def intake
            @submission.data_source
          end

          def calculator 
            intake.tax_calculator
          end

          def calculated_fields
            @nj1040_fields ||= calculator.calculate
          end
        end
      end
    end
  end
end