module Documents
  class RequestedDocumentsLaterController < DocumentUploadQuestionController
    include IntakeFromToken

    def self.show?(_)
      false
    end

    def next_path(params = {})
      send_requested_documents_later_documents_path
    end

    def not_found
      render layout: "application"
    end

    def self.document_type
      "Requested Later"
    end

  end
end
