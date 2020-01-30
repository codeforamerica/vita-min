class DocumentsController < ApplicationController
  before_action :require_sign_in

  def destroy
    document = current_intake.documents.find_by(id: params[:id])
    document.destroy if document.present?
    redirect_to params[:return_path]
  end
end