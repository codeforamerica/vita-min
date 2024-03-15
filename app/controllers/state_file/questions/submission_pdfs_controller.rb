module StateFile
  module Questions
    class SubmissionPdfsController < QuestionsController
      def show
        @submission = current_intake.efile_submissions.find_by(id: params[:id])
        error_redirect and return unless @submission.present?

        send_data @submission.generate_filing_pdf.read, filename: "submission.pdf", disposition: 'inline'
      end

      private

      def error_redirect
        flash[:alert] = "We encountered a problem generating your tax return pdf. For assistance, please reach out to FileYourStateTaxes client support."
        redirect_back(fallback_location: request.referer)
      end
    end
  end
end
