module CaseManagement
  class DocumentsController < ApplicationController
    include AccessControllable
    include FileResponseControllerHelper
    before_action :require_sign_in, :require_beta_tester
    layout "admin"

    def index
      @client = Client.find(params[:client_id])
      @documents = @client.documents
    end

    def show
      @document = Document.find(params[:id])
      render_active_storage_attachment @document.upload
    end

    def edit
      @document = Document.find(params[:id])
    end

    def update
      @document = Document.find(params[:id])
      @form = CaseManagement::DocumentForm.new(@document, document_params)
      if @form.valid?
        @form.save
        redirect_to case_management_client_documents_path(client_id: @document.client.id)
      else
        @document.errors.copy!(@form.errors)
        render :edit
      end
    end

    private

    def document_params
      params.require(:document).permit(:display_name)
    end
  end
end
