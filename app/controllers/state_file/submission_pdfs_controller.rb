module StateFile
  class SubmissionPdfsController < ApplicationController
    def show
      @submission = EfileSubmission.find_by(id: params[:id])
      error_redirect and return unless @submission.present?

      @pdf_attachment = @submission.data_source.submission_pdf
      if @submission.present? && !@pdf_attachment.present?
        begin
          @pdf_attachment = CreateSubmissionPdfJob.perform_now(@submission.id)
        rescue
          error_redirect and return
        end
      end

      # if !@pdf_attachment.present? || !@pdf_attachment.attachment.present?
      #   not_ready_redirect and return
      # end

      filled_tempfile = Tempfile.new("submission.pdf")
      @pdf_attachment.open do |original_tempfile|
        PdfForms.new.fill_form(
          original_tempfile.path,
          filled_tempfile.path
        )
      end

      send_data filled_tempfile.read, filename: "submission.pdf", disposition: 'inline'
    end
  end
end
