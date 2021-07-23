module Ctc
  module Questions
    class Filed2020YesController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake, _dependent)
        intake.filed_2020_yes?
      end

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