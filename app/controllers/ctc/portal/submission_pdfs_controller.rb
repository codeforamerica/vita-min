class Ctc::Portal::SubmissionPdfsController < Ctc::Portal::BaseAuthenticatedController
  include FilesConcern

  def show
    @submission = current_client.efile_submissions.find_by(id: params[:id])
    error_redirect and return unless @submission.present?

    submission = EfileSubmission.includes(:intake, :qualifying_dependents, :verified_address, :tax_return).find(@submission.id)

    begin
      output_file = submission.generate_filing_pdf(save: false, include_sensitive_fields: true)
      return send_data output_file.read, filename: submission.filing_pdf_filename, disposition: 'inline'
    rescue StandardError => e
      DatadogApi.increment('clients.pdf_generation_failed')
      error_redirect and return
    end
  end

  def error_redirect
    flash[:alert] = "We encountered a problem generating your tax return pdf. For assistance, please reach out to GetCTC client support."
    redirect_back(fallback_location: request.referer)
  end
end