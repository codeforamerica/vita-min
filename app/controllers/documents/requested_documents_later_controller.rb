module Documents
  class RequestedDocumentsLaterController < DocumentUploadQuestionController
    before_action :handle_session, only: :edit
    before_action :current_session_or_home, only: [:update, :destroy]
    skip_before_action :require_ticket

    rescue_from ActionController::InvalidAuthenticityToken do
      switch_locale do
        flash[:warning] = t("controllers.send_requested_documents_later_controller.not_found")
        redirect_to root_path
      end
    end

    def documents_request
      DocumentsRequest.find_by(id: session[:documents_request_id])
    end

    def edit
      @documents = documents_request.documents
      @form = form_class.new(documents_request, form_params)
    end

    def update
      @form = form_class.new(documents_request, form_params)
      if @form.valid?
        @form.save
        after_update_success
        track_document_upload
        redirect_to action: :edit
      else
        track_validation_error
        render :edit
      end
    end

    def destroy
      document = documents_request.documents.find_by(id: params[:id])

      if document.present?
        document.destroy

        redirect_to action: :edit
      else
        redirect_to root_path
      end
    end

    def self.show?(_)
      false
    end

    def show_progress?
      false
    end

    def next_path(params = {})
      send_requested_documents_later_documents_path
    end

    def not_found
      render layout: "application"
    end

    private

    def destroy_document_path(document)
      documents_remove_requested_document_path(id: document)
    end

    def self.document_type
      DocumentTypes::RequestedLater
    end

    def form_name
      "requested_document_upload_form"
    end

    def form_class
      RequestedDocumentUploadForm
    end

    def current_session_or_home
      if session[:documents_request_id].nil?
        flash[:warning] = t("controllers.send_requested_documents_later_controller.not_found")
        redirect_to root_path
      end
    end

    def handle_session
      redirect_to documents_requested_docs_not_found_path if no_token_or_session

      validate_token_and_create_session if needs_new_session?
    end

    def no_token_or_session
      params[:token].nil? && session[:documents_request_id].nil?
    end

    def needs_new_session?
      params[:token].present? && params_token_does_not_match_session_token
    end

    def params_token_does_not_match_session_token
      documents_request&.intake&.requested_docs_token != params[:token]
    end

    def create_new_documents_request_session(intake)
      docs_request = DocumentsRequest.create(intake: intake)
      session[:documents_request_id] = docs_request.id
    end

    def validate_token_and_create_session
      intake = Intake.find_for_requested_docs_token(params[:token])
      if intake.present?
        create_new_documents_request_session(intake)
      else
        redirect_to documents_requested_docs_not_found_path
      end
    end
  end
end
