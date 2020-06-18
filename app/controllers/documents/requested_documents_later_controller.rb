module Documents
  class RequestedDocumentsLaterController < DocumentUploadQuestionController
    before_action :handle_session, only: :edit
    before_action :current_session_or_home, only: [:update, :destroy]
    skip_before_action :require_ticket

    def documents_request
      DocumentsRequest.find(session[:documents_request_id])
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
      end

      redirect_to action: :edit
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
      documents_remove_requested_document_path(document)
    end

    def self.document_type
      "Requested Later"
    end

    def form_name
      "requested_document_upload_form"
    end

    def form_class
      RequestedDocumentUploadForm
    end

    def current_session_or_home
      if session[:documents_request_id].nil?
        redirect_to root_path
      end
    end

    def handle_session
      return if session[:documents_request_id].present?

      validate_token_and_create_session
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
