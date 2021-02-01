module Hub
  class DocumentsController < ApplicationController
    include AccessControllable
    include FilesConcern

    before_action :require_sign_in
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client

    layout "admin"

    def index
      ConsentPdf.new(@client.intake).create_consent_document if Document.where(document_type: "Consent Form 14446", intake: @intake).empty?

      @sort_order = sort_order
      @sort_column = sort_column
      @documents = @documents.except(:order).order({ @sort_column => @sort_order })
      @document = Document.new # used for form to upload documents
    end

    def show
      redirect_to transient_storage_url(@document.upload.blob)
    end

    def new; end

    def edit; end

    def create
      file_uploads = document_params.delete(:upload) || []
      # Validate that at least one doc is present
      @document = Document.new(document_params.merge(upload: file_uploads.first, uploaded_by: current_user))
      if @document.valid?
        file_uploads.each do |upload|
          Document.create!(document_params.merge(upload: upload, uploaded_by: current_user))
        end
        redirect_to(hub_client_documents_path(client_id: @client))
      else
        render :new
      end
    end

    def update
      if @document.update(document_params)
        redirect_to hub_client_documents_path(client_id: @document.client.id)
      else
        render :edit
      end
    end

    private

    def document_params
      params.require(:document)
          .permit(:document_type, :display_name, :tax_return_id, upload: [])
          .merge({ client: @client })
    end

    def sort_column
      %w[created_at display_name document_type].include?(params[:column]) ? params[:column] : "document_type"
    end

    def sort_order
      %w[asc desc].include?(params[:order]) ? params[:order] : "asc"
    end
  end
end
