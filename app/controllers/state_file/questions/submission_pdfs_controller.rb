module StateFile
  module Questions
    class SubmissionPdfsController < QuestionsController
      skip_before_action :redirect_if_in_progress_intakes_ended

      def show
        if current_intake.submission_pdf.attached?
          send_data current_intake.submission_pdf, filename: "submission.pdf", disposition: 'inline'
          return
        end
        # This is a fallback for legacy reasons - all submitted intakes should have an attached submission pdf
        @submission = current_intake.efile_submissions.find_by(id: params[:id])
        error_redirect and return unless @submission.present?

        send_data @submission.generate_filing_pdf.read, filename: "submission.pdf", disposition: 'inline'
      end

      private

      def error_redirect
        redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options)
      end
    end
  end
end
