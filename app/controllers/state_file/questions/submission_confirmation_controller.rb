module StateFile
  module Questions
    class SubmissionConfirmationController < QuestionsController
      def edit
        raise ActiveRecord::RecordNotFound unless EfileSubmission.where(data_source: current_intake).present?
        @show_download_button = current_intake.submission_pdf&.reload&.attached?
      end

      def prev_path
        nil
      end

      private
      def form_class
        NullForm
      end

      def card_postscript; end
    end
  end
end
