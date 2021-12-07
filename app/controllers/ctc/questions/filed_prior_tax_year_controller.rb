module Ctc
  module Questions
    class FiledPriorTaxYearController < QuestionsController
      include Ctc::ResetToStartIfIntakeNotPersistedConcern

      layout "intake"

      private

      def form_class
        NullForm
      end

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end
