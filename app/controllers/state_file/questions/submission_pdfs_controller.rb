module StateFile
  module Questions
    class SubmissionPdfsController < QuestionsController
      skip_before_action :redirect_if_in_progress_intakes_ended

      def show
        @submission = current_intake.efile_submissions.find_by(id: params[:id])
        error_redirect and return unless @submission.present?

        send_data @submission.generate_filing_pdf.read, filename: "submission.pdf", disposition: 'inline'
      end

      private

      def error_redirect
        redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options, us_state: params[:us_state])
      end
    end
  end
end
