module StateFile
  module Questions
    class SubmissionConfirmationController < AuthenticatedQuestionsController
      def edit
        raise ActiveRecord::RecordNotFound unless EfileSubmission.where(data_source: current_intake).present?
      end

      private
      def form_class
        NullForm
      end

      def card_postscript; end

    end
  end
end
