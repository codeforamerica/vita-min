module Ctc
  module Questions
    class FiledPriorTaxYearController < QuestionsController
      include Ctc::ResetToStartIfIntakeNotPersistedConcern
      include AnonymousIntakeConcern
      layout "intake"
      
      private

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end
