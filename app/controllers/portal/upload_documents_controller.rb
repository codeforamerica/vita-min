module Portal
  class UploadDocumentsController < PortalController
    before_action :find_or_create_document_request
    alias prev_path portal_complete_documents_request_path
    alias next_path portal_complete_documents_request_path
    helper_method :prev_path, :next_path, :illustration_path, :illustration_folder, :current_path, :document_type, :destroy_document_path
    layout "document_upload"

    def edit
      @form = form_class.new(@document_request)
      @hide_dont_have = true
      @documents = @document_request.documents
    end

    def update
      @form = form_class.new(@document_request, form_params)
      if @form.valid?
        @form.save
        flash[:notice] = I18n.t("portal.upload_documents.success")
        redirect_to action: :edit
      else
        flash.now[:error] = I18n.t("portal.upload_documents.error")
        render :edit
      end
    end

    def destroy
      document = current_client.documents.find_by(id: params[:id])
      document.destroy if document.present?

      redirect_to action: :edit
    end

    def complete_documents_request
      @document_request.touch(:completed_at) if @document_request.documents.length > 0
      redirect_to portal_root_path
    end

    private

    def document_type
      DocumentTypes::Other
    end

    def illustration_folder
      "questions"
    end
    def illustration_path
      "documents.svg"
    end

    def destroy_document_path(document)
      portal_upload_document_path(id: document.id)
    end

    def form_class
      RequestedDocumentUploadForm
    end

    def form_params
      params.fetch(form_class.form_param, {}).permit(form_class.attribute_names).merge(document_type: document_type)
    end

    def find_or_create_document_request
      @document_request = DocumentsRequest.find_or_create_by(completed_at: nil, intake: current_client.intake)
    end

    def current_path
      url_for
    end
  end
end