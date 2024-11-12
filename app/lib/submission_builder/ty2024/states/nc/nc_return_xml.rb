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

          def build_state_specific_tags(document)
            if !@submission.data_source.routing_number.nil? && !@submission.data_source.account_number.nil?
              document.at("ReturnState").add_child(financial_transaction)
            end
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
              {
                xml: SubmissionBuilder::Ty2024::States::Nc::Documents::D400ScheduleS,
                pdf: PdfFiller::NcD400ScheduleSPdf,
                include: adjustments_present?
              },
            ]

            supported_docs
          end

          def adjustments_present?
            calculated_fields = @submission.data_source.tax_calculator.calculate
            (calculated_fields[:NCD400_LINE_9]).positive? # TODO Also needs to check if Line 7 is positive but not in scope yet
          end

          def financial_transaction
            calculator = @submission.data_source.tax_calculator
            calculator.calculate

            FinancialTransaction.build(
              @submission,
              validate: false,
              kwargs: { refund_amount: calculator.refund_or_owed_amount }
            ).document.at("*")
          end
        end
      end
    end
  end
end
