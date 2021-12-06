module Ctc
  module Questions
    class AlreadyFiledController < QuestionsController
      include Ctc::ResetToStartIfIntakeNotPersistedConcern

      layout "yes_no_question"

      private

      def next_path
        @form.already_filed? ? offboarding_already_filed_path : super
      end

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end
