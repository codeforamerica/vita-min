module Documents
  class SendRequestedDocumentsLaterController < DocumentUploadQuestionController
    append_after_action :reset_session, :track_page_view, only: :success
    skip_before_action :require_intake

    def edit
      documents_request = DocumentsRequest.find(session[:documents_request_id])
      original_intake = documents_request.intake
      documents_request.documents.update_all(intake_id: original_intake.id)
      SendRequestedDocumentsToZendeskJob.perform_later(original_intake.id)
      redirect_to documents_requested_documents_success_path
    end

    def success
      render layout: "application"
    end

    def self.show?(_)
      false
    end

    def self.document_type
      nil
    end
  end
end
