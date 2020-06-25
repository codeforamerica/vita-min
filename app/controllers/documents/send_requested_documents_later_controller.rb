module Documents
  class SendRequestedDocumentsLaterController < DocumentUploadQuestionController
    append_after_action :reset_session, :track_page_view, only: :edit
    append_after_action :add_flash_message, :reset_session, only: :edit
    skip_before_action :require_ticket

    def edit
      documents_request = DocumentsRequest.find_by(id: session[:documents_request_id])
      if documents_request.nil?
        @flash_message = t("controllers.send_requested_documents_later_controller.not_found")
      else
        intake = documents_request.intake
        documents_request.documents.update_all(intake_id: intake.id)
        SendRequestedDocumentsToZendeskJob.perform_later(intake.id)
        @flash_message = t("controllers.send_requested_documents_later_controller.success")
      end
      redirect_to(root_path)
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

    def add_flash_message
      flash[:notice] = @flash_message
    end
  end
end

