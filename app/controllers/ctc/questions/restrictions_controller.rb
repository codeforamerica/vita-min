module Ctc
  module Questions
    class RestrictionsController < QuestionsController
      include Ctc::ResetToStartIfIntakeNotPersistedConcern

      layout "intake"

      def edit
        track_first_visit(:ctc_restrictions)
        super
      end

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
