module Ctc
  module Questions
    class SpouseAgi2019Controller < QuestionsController
      include Ctc::ResetToStartIfIntakeNotPersistedConcern

      layout "intake"

      def self.show?(intake)
        intake.spouse_filed_2019_filed_full_separate?
      end

      private

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end
