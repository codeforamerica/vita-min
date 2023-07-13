# frozen_string_literal: true
module SubmissionBuilder
  module Ty2022
    module States
      module Ny
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
            "NY"
          end

          private

          def documents_wrapper
            xml_doc = build_xml_doc("efile:processBO") do |xml|
              xml.filingKeys do
                xml.SOURCE_CD ""
                xml.EXT_TP_ID "123456789"
                xml.LIAB_PRD_BEG_DT "2023-04-17"
                xml.LIAB_PRD_END_DT "2023-04-19"
                xml.TAX_YEAR "2023"
              end

              xml.tiPrime do
                xml.FIRST_NAME "Ronald"
                xml.LAST_NAME "McDonald"
                xml.MAIL_LN_2_ADR "1 French Fry Way"
                xml.MAIL_CITY_ADR "Albany"
              end

              xml.composition do
                xml.forms
              end
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
            File.join(Rails.root, "vendor", "us_states", "NYSIndividual2022V5.0", "Common", "NysReturnState.xsd")
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
            supported_docs = [
              {
                xml: SubmissionBuilder::Ty2022::States::Ny::Documents::It201,
                pdf: nil,
                include: true
              },
            ]
            w2_docs = submission.intake.completed_w2s.map do |w2|
              {
                xml: SubmissionBuilder::Ty2021::Documents::IrsW2,
                pdf: nil,
                include: true,
                kwargs: { w2: w2 }
              }
            end
            supported_docs.push(*w2_docs)
            supported_docs
          end
        end
      end
    end
  end
end