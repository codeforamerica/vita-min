module Documents
  class SendRequestedDocumentsLaterController < DocumentUploadQuestionController
    include IntakeFromToken
    append_after_action :reset_session, :track_page_view, only: :success

    def edit
      SendRequestedDocumentsToZendeskJob.perform_later(current_intake.id)
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

