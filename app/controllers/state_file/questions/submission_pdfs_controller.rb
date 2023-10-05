module StateFile
  module Questions
    class SubmissionPdfsController < QuestionsController
      def show
        @submission = current_intake.efile_submissions.find_by(id: params[:id])
        error_redirect and return unless @submission.present?

        send_data @submission.generate_filing_pdf.read, filename: "submission.pdf", disposition: 'inline'
      end
    end
  end
end
