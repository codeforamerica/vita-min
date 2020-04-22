module Documents
  class RequestedDocumentsController < DocumentUploadQuestionController
    DOCUMENT_TYPE = 'Requested'.freeze

    def self.show?(_)
      false
    end

    def next_path(_ = {})
      send_requested_documents_documents_path
    end
  end
end
