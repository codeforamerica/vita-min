class Ctc::Portal::SubmissionPdfsController < Ctc::Portal::BaseAuthenticatedController
  include FilesConcern

  def show
    @submission = current_client.efile_submissions.find_by(id: params[:id])
    error_redirect and return unless @submission.present?

    @document = current_client.documents.find_by(tax_return_id: @submission.tax_return_id, document_type: DocumentTypes::Form1040.key)
    if @submission.present? && !@document.present?
      begin
        @document = CreateSubmissionPdfJob.perform_now(@submission.id)
      rescue
        error_redirect and return
      end
    end
    redirect_to transient_storage_url(@document.upload.blob)
  end

  def error_redirect
    flash[:alert] = "We encountered a problem generating your tax return pdf. For assistance, please reach out to GetCTC client support."
    redirect_back(fallback_location: request.referer)
  end
end