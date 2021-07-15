module Ctc
  module Questions
    class LifeSituations2020Controller < QuestionsController
      # TODO: Transition to Authenticated once we log in client
      include AnonymousIntakeConcern

      layout "intake"

      private

      def illustration_path; end

      def next_path
        # TODO: Change placeholder to /filing-status when available
        @form.cannot_claim_me_as_a_dependent != "yes" ? questions_use_gyr_path : questions_placeholder_question_path
      end
    end
  end
end