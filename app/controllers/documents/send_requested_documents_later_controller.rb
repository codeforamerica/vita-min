module Documents
  class SendRequestedDocumentsLaterController < DocumentUploadQuestionController
    append_after_action :reset_session, :track_page_view, only: :edit
    skip_before_action :require_intake

    def edit
      @documents_request = DocumentsRequest.find_by(id: session[:documents_request_id])
      if @documents_request.nil?
        flash[:warning] = t("controllers.send_requested_documents_later_controller.not_found")
      else
        @documents_request.touch(:completed_at)
        flash[:notice] = t("controllers.send_requested_documents_later_controller.success")
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
  end
end

