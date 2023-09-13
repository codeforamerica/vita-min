# frozen_string_literal: true
module SubmissionBuilder
  module Ty2022
    module States
      module Az
        class IndividualReturn < SubmissionBuilder::Document
          def document
            document = build_xml_doc('efile:ReturnState', stateSchemaVersion: "AZIndividual2022v1.1")
            document.at("ReturnState").add_child(authentication_header)
            document.at("ReturnState").add_child(return_header)
            document.at("ReturnState").add_child("<ReturnDataState></ReturnDataState>")
            document.at("ReturnDataState").add_child(documents_wrapper)
            document
          end

          def self.state_abbreviation
            "AZ"
          end

          def self.return_type
            "Form140"
          end

          def pdf_documents
            included_documents.map { |item| item if item.pdf }.compact
          end

          private

          def documents_wrapper
            standard_deductions = {
              "single" => 12950
            }

            xml_doc = build_xml_doc("Form140") do |xml|
              xml.FiledUnderExtension "No"
              xml.FilingStatus @submission.data_source.filing_status.capitalize
              xml.Additions do
                xml.FedAdjGrossIncome @submission.data_source.agi
                xml.ModFedAdjGrossInc @submission.data_source.agi
              end
              xml.AzAdjSubtotal @submission.data_source.agi
              xml.TotalSubtractions @submission.data_source.agi # Subtract lines 24 through 34c from line 19 (AzAdjSubtotal)
              xml.Subtotal @submission.data_source.agi # subtract line 36 from 35
              xml.AZAdjGrossIncome @submission.data_source.agi
              xml.DeductionAmt do
                xml.DeductionTypeIndc "Standard"
                xml.AZDeductions standard_deductions.fetch(@submission.data_source.filing_status)
                xml.AZTaxableInc 0
                xml.ComputedTax 0
                xml.BalanceOfTaxDue 0
              end
              xml.TaxDueOrOverpayment do
                xml.TaxDue 0
              end
              xml.AmtOwed 0
            end

            xml_doc.at('*')
          end

          def document_fragment(document)
            document[:xml_class].build(@submission, validate: false, kwargs: document[:kwargs]).document.at("*")
          end

          def authentication_header
            SubmissionBuilder::Ty2022::States::AuthenticationHeader.build(@submission, validate: false).document.at("*")
          end

          def return_header
            SubmissionBuilder::Ty2022::States::ReturnHeader.build(@submission, validate: false).document.at("*")
          end

          def schema_file
            File.join(Rails.root, "vendor", "us_states", "unpacked", "AZIndividual2022v1.1", "AZIndividual", "IndividualReturnAZ140.xsd")
          end

          def attached_documents
            @attached_documents ||= xml_documents.map { |doc| { xml_class: doc.xml, kwargs: doc.kwargs } }
          end

          def xml_documents
            included_documents.map { |item| item if item.xml }.compact
          end

          def included_documents
            supported_documents.map { |item| OpenStruct.new(**item, kwargs: item[:kwargs] || {}) if item[:include] }.compact
          end

          def supported_documents
            supported_docs = [
              {
                xml: nil,
                pdf: PdfFiller::Az140Pdf,
                include: true
              },
            ]
            supported_docs
          end
        end
      end
    end
  end
end