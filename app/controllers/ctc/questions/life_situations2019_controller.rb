module Ctc
  module Questions
    class LifeSituations2019Controller < QuestionsController

      layout "intake"

      private

      def form_class
        NullForm
      end

      def illustration_path; end
    end
  end
end