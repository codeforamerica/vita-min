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
        flash[:alert] = I18n.t("state_file.questions.return_status.accepted.pdf_error")
        redirect_to StateFile::Questions::ReturnStatusController.to_path_helper(
          us_state: current_intake.state_code,
          action: :edit
        )
      end
    end
  end
end
