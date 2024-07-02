module SubmissionBuilder
  module Ty2022
    module States
      class StateReturn < SubmissionBuilder::Document
        def authentication_header
          SubmissionBuilder::Ty2022::States::AuthenticationHeader.build(@submission, validate: false).document.at("*")
        end

        def return_header
          SubmissionBuilder::Ty2022::States::ReturnHeader.build(@submission, validate: false).document.at("*")
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
      end
    end
  end
end