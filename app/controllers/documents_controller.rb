class DocumentsController < ApplicationController
  include AccessControllable
  include FileResponseControllerHelper

  before_action :require_sign_in, :require_beta_tester, only: [:index, :show, :edit, :update]
  before_action :require_intake, only: [:destroy]
  layout "admin", only: [:index]

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
    @document.update(document_params)
    redirect_to client_documents_path(client_id: @document.client.id)
  end

  def destroy
    document = current_intake.documents.find_by(id: params[:id])

    if document.present?
      document.destroy

      redirect_to helpers.edit_document_path(document.document_type)
    else
      redirect_to overview_documents_path
    end
  end

  private

  def document_params
    params.require(:document_form).permit(:display_name)
  end
end
