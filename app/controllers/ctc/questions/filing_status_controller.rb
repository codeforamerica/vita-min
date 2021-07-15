module Ctc
  module Questions
    class FilingStatusController < QuestionsController
      include AnonymousIntakeConcern

      def next_path
        return questions_placeholder_question_path if @form.intake.filing_status == "single"

        super
      end

      private

      def illustration_path; end

    end
  end
end