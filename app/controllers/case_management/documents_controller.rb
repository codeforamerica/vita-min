module CaseManagement
  class DocumentsController < ApplicationController
    include AccessControllable
    include FileResponseControllerHelper

    before_action :require_sign_in
    # /case_management/clients/:client_id/documents
    load_and_authorize_resource :client
    # load_and_authorize_resource :intake, through: :client
    load_and_authorize_resource through: :intake

    # 1. attach documents to client, not intake (eventually move documents off intakes during questions flow)
    # 2. check permisions using intakes, not clients (this approaches the single model version)
    # 3. write some custom code, base intake permissions off clients, and use intake_id in the url
      # /case_management/intakes/:intake_id/documents
      # load_and_authorize_resource :intake
      # load_and_authorize_resource through: :intake
    # 4. try to write custom code and don't rely on load_and_authorize resource to work out of the box

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
        redirect_to case_management_client_documents_path(client_id: @document.intake.client.id)
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
