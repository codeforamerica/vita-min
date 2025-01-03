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

          def self.ptin 
            "P99999999"  
          end

          def self.preparer_person_name
            "Self Prepared"
          end

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

          def build_state_specific_tags(document)
            if !@submission.data_source.routing_number.nil? && !@submission.data_source.account_number.nil?
              document.at("ReturnState").add_child(financial_transaction)
            end
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

            supported_docs += nj_2450s
            supported_docs += schedule_nj_hcc
            supported_docs += combined_w2s
            supported_docs += additional_dependents
            supported_docs
          end

          def nj_2450s
            docs = []

            # Must call calculator directly because these aren't lines on the NJ 1040
            if calculator.line_59_primary&.positive? || calculator.line_61_primary&.positive?
              docs << {
                xml: SubmissionBuilder::Ty2024::States::Nj::Documents::Nj2450,
                pdf: PdfFiller::Nj2450Pdf,
                include: true,
                kwargs: { primary_or_spouse: :primary }
              }
            end

            if calculator.line_59_spouse&.positive? || calculator.line_61_spouse&.positive?
              docs << {
                xml: SubmissionBuilder::Ty2024::States::Nj::Documents::Nj2450,
                pdf: PdfFiller::Nj2450Pdf,
                include: true,
                kwargs: { primary_or_spouse: :spouse }
              }
            end

            docs
          end

          def schedule_nj_hcc
            docs = []

            if calculated_fields.fetch(:NJ1040_LINE_53C_CHECKBOX)
              docs << {
                xml: SubmissionBuilder::Ty2024::States::Nj::Documents::ScheduleNjHcc,
                pdf: PdfFiller::ScheduleNjHccPdf,
                include: true,
              }
            end

            docs
          end

          def additional_dependents
            docs = []

            if @submission.data_source.dependents.count > 4
              docs << {
                xml: nil,
                pdf: PdfFiller::NjAdditionalDependentsPdf,
                include: true,
              }
            end
            docs
          end

          def calculator 
            @submission.data_source.tax_calculator
          end

          def calculated_fields
            @calculated_fields ||= calculator.calculate 
          end

          def financial_transaction
            FinancialTransaction.build(
              @submission,
              validate: false,
              kwargs: { refund_amount: calculated_fields.fetch(:NJ1040_LINE_80) }
            ).document.at("*")
          end
        end
      end
    end
  end
end