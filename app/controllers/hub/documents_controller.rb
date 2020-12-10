module Hub
  class DocumentsController < ApplicationController
    include AccessControllable
    include FilesConcern

    before_action :require_sign_in
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client

    layout "admin"

    def index
      @sort_order = sort_order
      @sort_column = sort_column
      @documents = @documents.except(:order).order({ @sort_column => @sort_order })
      @document = Document.new # used for form to upload documents
    end

    def show
      redirect_to transient_storage_url(@document.upload.blob)
    end

    def edit; end

    def create
      document_params[:upload].each do |file_upload|
        Document.create!(
          client: @client,
          intake: @client.intake,
          document_type: DocumentTypes::Other.key,
          upload: file_upload
        )
      end
      redirect_to(hub_client_documents_path(client_id: @client))
    end

    def update
      @form = Hub::DocumentForm.new(@document, document_params)
      if @form.valid?
        @form.save
        redirect_to hub_client_documents_path(client_id: @document.client.id)
      else
        @document.errors.copy!(@form.errors)
        render :edit
      end
    end

    private

    def document_params
      params.require(:document).permit(:display_name, upload: [])
    end

    def sort_column
      %w[created_at display_name document_type].include?(params[:column]) ? params[:column] : "document_type"
    end

    def sort_order
      %w[asc desc].include?(params[:order]) ? params[:order] : "asc"
    end
  end
end
