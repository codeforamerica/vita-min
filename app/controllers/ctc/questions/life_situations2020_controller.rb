module Ctc
  module Questions
    class LifeSituations2020Controller < QuestionsController
      # TODO: Transition to Authenticated once we log in client
      include AnonymousIntakeConcern

      layout "intake"

      private

      def illustration_path; end

      def next_path
        @form.cannot_claim_me_as_a_dependent != "yes" ? questions_use_gyr_path : super
      end
    end
  end
end