module Documents
  class RequestedDocumentsLaterController < DocumentUploadQuestionController
    skip_before_action :require_intake

    def documents_request
      if session[:documents_request_id]
        DocumentsRequest.find(session[:documents_request_id])
      else
        if params[:token]
          intake = Intake.find_for_requested_docs_token(params[:token])
          # redirect_to root_path if !intake
          docs_request = DocumentsRequest.create(intake: intake)
          session[:documents_request_id] = docs_request.id
          docs_request
        end
      end
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

    private

    def form_name
      "requested_document_upload_form"
    end

    def self.form_class
      RequestedDocumentUploadForm
    end

    private

    def destroy_document_path(document)
      destroy_requested_document_path(document)
    end
  end
end
