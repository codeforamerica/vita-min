module Documents
  class SendRequestedDocumentsLaterController < DocumentUploadQuestionController
    append_after_action :reset_session, :track_page_view, only: :success
    skip_before_action :require_ticket

    def edit
      documents_request = DocumentsRequest.find_by(id: session[:documents_request_id])
      if documents_request.nil?
        redirect_to(
          root_path,
          notice: t("controllers.send_requested_documents_later_controller.not_found")
        )
      else
        intake = documents_request.intake
        documents_request.documents.update_all(intake_id: intake.id)
        SendRequestedDocumentsToZendeskJob.perform_later(intake.id)
        redirect_to documents_requested_documents_success_path
      end
    end

    def success
      render layout: "application"
    end

    def self.show?(_)
      false
    end

    def show_progress?
      false
    end

    def self.document_type
      nil
    end
  end
end

