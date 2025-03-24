module StateFile
  module Questions
    class SubmissionConfirmationController < QuestionsController
      def edit
        raise ActiveRecord::RecordNotFound unless EfileSubmission.where(data_source: current_intake).present?
        Rails.logger.info "PDF attached?: #{current_intake.submission_pdf.attached?}"
        Rails.logger.info "PDF blob: #{current_intake.submission_pdf.blob.inspect}"
        @show_download_button = current_intake.submission_pdf.attached?
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
