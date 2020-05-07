class DocumentsController < ApplicationController
  before_action :require_intake, only: :destroy

  def destroy
    document = current_intake.documents.find_by(id: params[:id])

    if document.present?
      document.destroy

      redirect_to helpers.edit_document_path(document.document_type)
    else
      redirect_to overview_documents_path
    end
  end

  def destroy_requested
    document = Document.find_by(id: params[:id])

    document.destroy
    redirect_to helpers.edit_document_path(document.document_type)
  end
end
