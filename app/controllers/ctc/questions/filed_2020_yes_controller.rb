module Ctc
  module Questions
    class Filed2020YesController < QuestionsController
      # TODO: Transition to Authenticated once we log in client
      include AnonymousIntakeConcern

      layout "intake"

      def self.show?(intake)
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