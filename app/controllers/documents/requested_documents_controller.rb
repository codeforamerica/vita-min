module Documents
  class RequestedDocumentsController < DocumentUploadQuestionController
    def self.show?(intake)
      false
    end

    def next_path(params = {})
      send_requested_documents_documents_path
    end

    def self.document_type
      "Requested"
    end
  end
end
