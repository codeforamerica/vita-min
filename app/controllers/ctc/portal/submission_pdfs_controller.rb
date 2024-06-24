class Ctc::Portal::SubmissionPdfsController < Ctc::Portal::BaseAuthenticatedController
  skip_before_action :redirect_if_read_only
  include FilesConcern

  def show
    @submission = current_client.efile_submissions.find_by(id: params[:id])
    error_redirect and return unless @submission.present?

    @document = current_client.documents.find_by(tax_return_id: @submission.tax_return_id, document_type: DocumentTypes::Form1040.key)
    if @submission.present? && !@document.present?
      begin
        @document = StateFile::CreateSubmissionPdfJob.perform_now(@submission.id)
      rescue
        error_redirect and return
      end
    end

    if !@document.upload.attachment.present?
      not_ready_redirect and return
    end

    pdf_basename = @document.display_name.split('.').first
    filled_tempfile = Tempfile.new([pdf_basename, ".pdf"])
    @document.upload.open do |original_tempfile|
      PdfForms.new.fill_form(
        original_tempfile.path,
        filled_tempfile.path,
        PdfFiller::Irs1040Pdf.new(@submission).sensitive_fields_hash_for_pdf
      )
    end

    send_data filled_tempfile.read, filename: @document.display_name, disposition: 'inline'
  end

  def error_redirect
    flash[:alert] = "We encountered a problem generating your tax return pdf. For assistance, please reach out to GetCTC client support."
    redirect_back(fallback_location: request.referer)
  end

  def not_ready_redirect
    flash[:alert] = I18n.t("views.ctc.portal.submission_pdfs.not_ready")
    redirect_back(fallback_location: request.referer)
  end
end
