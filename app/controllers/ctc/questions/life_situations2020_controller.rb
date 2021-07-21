module Ctc
  module Questions
    class LifeSituations2020Controller < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      private

      def illustration_path; end

      def next_path
        @form.cannot_be_claimed_as_dependent? ? questions_use_gyr_path : super
      end
    end
  end
end