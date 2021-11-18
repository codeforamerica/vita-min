module Hub
  class DocumentsController < ApplicationController
    include AccessControllable
    include FilesConcern

    before_action :require_sign_in
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client
    helper_method :transient_storage_url

    layout "hub"

    def index
      @documents = sorted_documents.active
    end

    def archived
      @documents = sorted_documents.archived
      @show_archived_index = true
      render :index
    end

    def show
      log_document_access!
      redirect_to transient_storage_url(@document.upload.blob)
    end

    def confirm; end

    def new; end

    def edit; end

    def create
      @document = @client.documents.new(document_params.merge({ uploaded_by: current_user }))
      render :new and return unless @document.save

      next_path = @document.confirmation_needed? ? confirm_hub_client_document_path(id: @document) : hub_client_documents_path(client_id: @client)
      redirect_to next_path
    end

    def update
      if @document.update(document_params)
        redirect_to hub_client_documents_path(client_id: @document.client.id)
      else
        render :edit
      end
    end

    def destroy
      if params[:reupload].present?
        @document.destroy!

        flash[:notice] = "Please upload correct document for #{@client.legal_name}."
        render :new and return
      else
        @document.update(archived: true)
        flash[:notice] = "Document archived."
      end

      redirect_back(fallback_location: hub_client_documents_path)
    end

    private

    def sorted_documents
      @sort_order = sort_order
      @sort_column = sort_column
      @documents.except(:order).order({ @sort_column => @sort_order })
    end

    def log_document_access!
      AccessLog.create!(
        user: current_user,
        record: @document,
        created_at: DateTime.now,
        event_type: "viewed_document",
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
      )
    end

    def document_params
      params.require(:document).permit(:document_type, :display_name, :tax_return_id, :archived, :upload)
    end

    def sort_column
      %w[created_at display_name document_type].include?(params[:column]) ? params[:column] : "document_type"
    end

    def sort_order
      %w[asc desc].include?(params[:order]) ? params[:order] : "asc"
    end
  end
end
