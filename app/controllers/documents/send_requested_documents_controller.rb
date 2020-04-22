module Documents
  class SendRequestedDocumentsController < DocumentUploadQuestionController
    def edit
      SendRequestedDocumentsToZendeskJob.perform_later(current_intake.id)
      redirect_to documents_requested_documents_success_path
    end

    def self.show?(_)
      false
    end

    def self.document_type
      nil
    end
  end
end

