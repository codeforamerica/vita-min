class DocumentsController < ApplicationController
  before_action :require_sign_in

  def destroy
    document = current_intake.documents.find_by(id: params[:id])

    if document.present?
      document.destroy

      redirect_to helpers.edit_document_path(document.document_type)
    else
      redirect_to documents_overview_questions_path
    end
  end
end
