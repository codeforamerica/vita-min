module Portal
  class UploadDocumentsController < PortalController
    before_action :find_or_create_document_request
    alias prev_path portal_root_path
    alias next_path portal_root_path
    helper_method :prev_path, :next_path, :illustration_path, :current_path, :document_type, :destroy_document_path
    layout "document_upload"

    def new
      @form = form_class.new(@document_request)
      @form_method = "post"
      @documents = @document_request.documents
    end

    def create
      @form = form_class.new(@document_request, form_params)
      if @form.valid?
        @form.save
        flash[:notice] = I18n.t("portal.upload_documents.success")
        redirect_to action: :new
      else
        flash.now[:error] = I18n.t("portal.upload_documents.error")
        render :new
      end
    end

    def destroy
      document = current_client.documents.find_by(id: params[:id])
      document.destroy if document.present?

      redirect_to action: :new
    end

    private

    def document_type
      DocumentTypes::RequestedLater
    end

    def illustration_path; end

    def current_path
      portal_upload_documents_path
    end

    def destroy_document_path(document)
      portal_upload_document_path(id: document.id)
    end

    def form_class
      RequestedDocumentUploadForm
    end

    def form_params
      params.fetch(form_class.form_param, {}).permit(form_class.attribute_names)
    end

    def find_or_create_document_request
      @document_request = DocumentsRequest.where(intake: current_client.intake).where("created_at >= ?", current_client.current_sign_in_at).first || DocumentsRequest.create(intake: current_client.intake)
    end
  end
end