module StateFile
  module Questions
    class SubmissionConfirmationController < QuestionsController
      def edit
        raise ActiveRecord::RecordNotFound unless EfileSubmission.where(data_source: current_intake).present?
        @show_download_button = current_intake.submission_pdf.attached?
        @after_tax_deadline = StateInformationService.after_payment_deadline?(app_time, current_intake.state_code)
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
