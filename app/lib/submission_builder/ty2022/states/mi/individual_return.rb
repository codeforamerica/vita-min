# frozen_string_literal: true
module SubmissionBuilder
  module Ty2022
    module States
      module Mi
        class IndividualReturn < SubmissionBuilder::Document
          def document
            document = build_xml_doc('efile:ReturnState')
            document.at("ReturnState").add_child(authentication_header)
            document.at("ReturnState").add_child(return_header)
            document.at("ReturnState").add_child("<ReturnDataState></ReturnDataState>")
            document.at("ReturnDataState").add_child(documents_wrapper)
            attached_documents.each do |attached|
              document.at('forms').add_child(document_fragment(attached))
            end
            document
          end

          def self.state_abbreviation
            "MI"
          end

          private

          def documents_wrapper
            xml_doc = build_xml_doc("efile:Form1040") do |xml|
              xml.SchoolDistrict @submission.intake.school_district
              if @submission.tax_return.filing_status == "single"
                xml.FilingStatus do
                  xml.Single "X"
                end
              end
              if @submission.intake.resident == true
                xml.Residency do
                  xml.Resident "X"
                end
              end
              xml.AdjustedGrossIncome @submission.intake.agi
              xml.IncomeTax @submission.intake.income_tax
              xml.StateUseTax @submission.intake.state_use_tax
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
            File.join(Rails.root, "vendor", "us_states", "MIInd2022V1.0", "MIIndividual", "IndividualReturnMI1040.xsd")
          end

          def attached_documents
            @attached_documents ||= xml_documents.map { |doc| { xml_class: doc.xml, kwargs: doc.kwargs } }
          end

          def xml_documents
            included_documents.map { |item| item if item.xml }.compact
          end

          def pdf_documents
            included_documents.map { |item| item if item.pdf }.compact
          end

          def included_documents
            supported_documents.map { |item| OpenStruct.new(**item, kwargs: item[:kwargs] || {}) if item[:include] }.compact
          end

          def supported_documents
            supported_docs = []
            supported_docs
          end
        end
      end
    end
  end
end