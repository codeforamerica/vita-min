module Ctc
  module Questions
    class LifeSituations2020Controller < QuestionsController
      # TODO: Transition to Authenticated once we log in client
      include AnonymousIntakeConcern

      layout "intake"

      # TBD

      private

      def form_class
        NullForm
      end

      def illustration_path; end
    end
  end
end