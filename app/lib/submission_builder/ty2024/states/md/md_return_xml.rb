# frozen_string_literal: true

module SubmissionBuilder
  module Ty2024
    module States
      module Md
        class MdReturnXml < SubmissionBuilder::StateReturn

          private

          def attached_documents_parent_tag
            'ReturnDataState'
          end

          def build_xml_doc_tag
            "ReturnState"
          end

          def state_schema_version
            "MDIndividual2023v1.0"
          end

          def documents_wrapper
            nil
          end

          def schema_file
            SchemaFileLoader.load_file("us_states", "unpacked", "MDIndividual2023v1.0", "MDIndividual", "IndividualReturnMD502.xsd")
          end

          def form1099g_builder
            SubmissionBuilder::Ty2024::States::Md::Documents::Md1099G
          end

          def supported_documents
            calculated_fields = @submission.data_source.tax_calculator.calculate
            has_income_from_taxable_pensions_iras_annuities = calculated_fields.fetch(:MD502_LINE_1D)&.to_i.positive?
            has_md_su_subtractions = calculated_fields.fetch(:MD502_SU_LINE_1).positive?

            supported_docs = []
            supported_docs << {
              xml: SubmissionBuilder::Ty2024::States::Md::Documents::Md502,
              pdf: PdfFiller::Md502Pdf,
              include: true
            }
            supported_docs << {
              xml: SubmissionBuilder::Ty2024::States::Md::Documents::Md502b,
              pdf: PdfFiller::Md502bPdf,
              include: @submission.data_source.dependents.count.positive?
            }
            supported_docs << {
              xml: SubmissionBuilder::Ty2024::States::Md::Documents::Md502Su,
              pdf: PdfFiller::Md502SuPdf,
              include: has_md_su_subtractions,
            }
            supported_docs << {
              xml: SubmissionBuilder::Ty2024::States::Md::Documents::Md502R,
              pdf: PdfFiller::Md502RPdf,
              include: has_income_from_taxable_pensions_iras_annuities
            }
            supported_docs << {
              xml: SubmissionBuilder::Ty2024::States::Md::Documents::Md502Cr,
              pdf: PdfFiller::Md502CrPdf,
              include: true,
            }
            supported_docs += form1099gs
            supported_docs << {
              xml: nil,
              pdf: PdfFiller::MdEl101Pdf,
              include: true
            }

            supported_docs += combined_w2s
            supported_docs += form1099rs
            supported_docs += form1099ints
            supported_docs
          end
        end
      end
    end
  end
end
