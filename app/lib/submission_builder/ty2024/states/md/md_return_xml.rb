# frozen_string_literal: true

module SubmissionBuilder
  module Ty2024
    module States
      module Md
        class MdReturnXml < SubmissionBuilder::StateReturn
          def form_has_non_zero_amounts(form_prefix, calculated_fields)
            lines = calculated_fields.keys.select { |line_name| line_name.starts_with?(form_prefix) }
            lines.any? do |line_num|
              calculated_fields.fetch(line_num).present? && calculated_fields.fetch(line_num) != 0
            end
          end

          private

          def attached_documents_parent_tag
            'ReturnDataState'
          end

          def build_xml_doc_tag
            "efile:ReturnState"
          end

          def state_schema_version
            "MDIndividual2024v1.0"
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
            SchemaFileLoader.load_file("us_states", "unpacked", "MDIndividual2024v1.0", "MDIndividual", "IndividualReturnMD502.xsd")
          end

          def form1099g_builder
            SubmissionBuilder::Ty2024::States::Md::Documents::Md1099G
          end

          def supported_documents
            calculated_fields = @submission.data_source.tax_calculator.calculate
            has_income_from_taxable_pensions_iras_annuities = calculated_fields.fetch(:MD502_LINE_1D)&.to_i&.positive?
            has_income_from_social_security_benefits = @direct_file_data.fed_ssb&.to_i&.positive?
            has_md_su_subtractions = calculated_fields.fetch(:MD502_LINE_13).positive? || form_has_non_zero_amounts("MD502_SU_", calculated_fields)
            has_individual_tax_credits = (calculated_fields.fetch(:MD502_LINE_24).positive? && @intake.tax_calculator.calculate.fetch(:MD502_DEDUCTION_METHOD) == "S") || calculated_fields.fetch(:MD502_LINE_43).positive?

            supported_docs = [
              {
                xml: SubmissionBuilder::Ty2024::States::Md::Documents::Md502,
                pdf: PdfFiller::Md502Pdf,
                include: true
              },
              {
                xml: SubmissionBuilder::Ty2024::States::Md::Documents::Md502b,
                pdf: PdfFiller::Md502bPdf,
                include: @submission.data_source.dependents.count.positive?
              },
              {
                xml: SubmissionBuilder::Ty2024::States::Md::Documents::Md502Su,
                pdf: PdfFiller::Md502SuPdf,
                include: has_md_su_subtractions,
              },
              {
                xml: SubmissionBuilder::Ty2024::States::Md::Documents::Md502Cr,
                pdf: PdfFiller::Md502CrPdf,
                include: has_individual_tax_credits,
              },
              {
                xml: SubmissionBuilder::Ty2024::States::Md::Documents::Md502R,
                pdf: PdfFiller::Md502RPdf,
                include: has_income_from_taxable_pensions_iras_annuities || has_income_from_social_security_benefits
              },
              {
                xml: nil,
                pdf: PdfFiller::MdEl101Pdf,
                include: true
              },
            ]

            supported_docs += form1099gs # must be sequenced here
            supported_docs += combined_w2s
            supported_docs += form1099rs
            supported_docs
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
