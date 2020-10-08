module CaseManagement
  class DocumentsController < ApplicationController
    include AccessControllable
    include FileResponseControllerHelper

    before_action :require_sign_in
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client

    layout "admin"

    def index
      @sort_order = sort_order
      @sort_column = sort_column
      @documents = @documents.order({ @sort_column => @sort_order })
    end

    def show
      render_active_storage_attachment @document.upload
    end

    def edit
    end

    def update
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

    def sort_column
      %w[created_at display_name document_type].include?(params[:sort]) ? params[:sort] : "document_type"
    end

    def sort_order
      %w[asc desc].include?(params[:order]) ? params[:order] : "asc"
    end
  end
end
