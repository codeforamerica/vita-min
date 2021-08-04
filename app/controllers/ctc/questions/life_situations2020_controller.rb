module Ctc
  module Questions
    class LifeSituations2020Controller < QuestionsController
      layout "yes_no_question"

      private

      def illustration_path; end

      def method_name
        "can_be_claimed_as_dependent"
      end

      def next_path
        @form.can_be_claimed_as_a_dependent? ? questions_use_gyr_path : super
      end
    end
  end
end