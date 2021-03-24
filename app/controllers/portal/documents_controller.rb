module Portal
  class DocumentsController < PortalController
    include FilesConcern
    before_action :load_document

    def show
      redirect_to transient_storage_url(@document.upload.blob)
    end

    def load_document
      @document = current_client.documents.find_by(id: params[:id])
      render "public_pages/page_not_found", status: 404 unless @document.present?
    end
  end
end