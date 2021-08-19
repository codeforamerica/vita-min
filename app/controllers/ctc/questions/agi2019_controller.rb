module Ctc
  module Questions
    class Agi2019Controller < QuestionsController
      include Ctc::ResetToStartIfIntakeNotPersistedConcern

      layout "intake"

      def self.show?(intake)
        intake.filed_2019_filed_full? || intake.filed_2019_filed_non_filer?
      end

      private

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end
