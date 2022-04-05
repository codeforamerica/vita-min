module Ctc
  module Questions
    class RestrictionsController < QuestionsController
      include Ctc::ResetToStartIfIntakeNotPersistedConcern

      layout "intake"

      private

      def form_class
        NullForm
      end

      def illustration_path
        "ineligible.svg"
      end
    end
  end
end
