class DocumentsController < ApplicationController
  before_action :require_intake, only: [:destroy]

  def index
    @client = Client.find(params[:client_id])
    @documents = @client.documents
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
end
