module Ctc
  module Questions
    class HeadOfHouseholdController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(_intake)
        false
      end

      def next_path
        Ctc::Questions::ConfirmDependentsController.to_path_helper
      end

      private

      def illustration_path; end
    end
  end
end
