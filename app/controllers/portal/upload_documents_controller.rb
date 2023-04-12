module Portal
  class UploadDocumentsController < PortalController
    alias next_path portal_overview_documents_path
    helper_method :prev_path, :next_path, :illustration_path, :illustration_folder, :current_path, :document_type, :destroy_document_path
    layout "document_upload"
    helper_method :document_type_keys

    def prev_path
      @prev_path
    end

    def index
      @documents = current_client.documents
      @prev_path = portal_root_path
      render layout: "intake"
    end

    def edit
      @prev_path = portal_overview_documents_path
      @form = form_class.new(current_client.intake)
      if params[:type].present?
        @documents = current_client.documents.where(document_type: params[:type])
        @document_type = DocumentTypes::ALL_TYPES.find { |doc_type| doc_type.key == params[:type] }
      else
        @documents = current_client.documents
      end
    end

    def update
      @prev_path = portal_overview_documents_path
      @form = form_class.new(current_client.intake, form_params)
      if @form.valid?
        @form.save
        current_client.tax_returns.each do |tax_return|
          tax_return.transition_to!(:intake_ready) if %w(intake_in_progress intake_needs_doc_help).include? tax_return.current_state
        end
        flash[:notice] = I18n.t("portal.upload_documents.success")
        redirect_to portal_upload_documents_path(type: form_params[:document_type])
      else
        flash.now[:error] = I18n.t("portal.upload_documents.error")
        render :edit
      end
    end

    def destroy
      document = current_client.documents.find_by(id: params[:id])
      document.destroy if document.present?

      redirect_to portal_upload_documents_path(type: params[:document_type])
    end

    private

    def document_type
      @document_type || DocumentTypes::Other
    end

    def illustration_path; end

    def destroy_document_path(document)
      portal_upload_document_path(id: document.id, document_type: document.document_type)
    end

    def form_class
      Portal::DocumentUploadForm
    end

    def form_params
      params.fetch(form_class.form_param, {}).permit(form_class.attribute_names)
    end

    def current_path
      url_for
    end

    def document_type_keys
      current_client.intake.relevant_intake_document_types.map(&:key)
    end
  end
end
