module StateFile
  module Questions
    class SubmissionPdfsController < QuestionsController
      def show
        # fixes Rails hot reload, see method source gem PR #73
        if Rails.env.development?
          MethodSource.instance_variable_set(:@lines_for_file, {})
        end
        @submission = current_intake.efile_submissions.find_by(id: params[:id])
        error_redirect and return unless @submission.present?

        send_data @submission.generate_filing_pdf.read, filename: "submission.pdf", disposition: 'inline'
      end
    end
  end
end
