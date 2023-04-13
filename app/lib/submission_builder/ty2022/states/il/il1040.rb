module SubmissionBuilder
  module Ty2022
    module States
      module Il
        class Il1040 < SubmissionBuilder::Document
          def document
            document = build_xml_doc('efile:ReturnState', stateSchemaVersion: 'ILIndividual2022V1.0')
            document.at("ReturnState").add_child(authentication_header)
            document.at("ReturnState").add_child(return_header)
            document.at("ReturnState").add_child("<ReturnDataState></ReturnDataState>")
            attached_documents.each do |attached|
              document.at("ReturnDataState").add_child(document_fragment(attached))
            end
            document
          end

          private

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
            File.join(Rails.root, "vendor", "us_states", "ILIndividual2022V1.0", "IL Individual", "IndividualReturnIL1040.xsd")
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
                xml: SubmissionBuilder::Ty2022::States::Il::Documents::Il1040,
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
