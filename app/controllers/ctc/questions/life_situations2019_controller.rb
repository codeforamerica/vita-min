module Ctc
  module Questions
    class LifeSituations2019Controller < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        intake.filed_2019_yes?
      end

      private

      def form_class
        NullForm
      end

      def illustration_path; end
    end
  end
end