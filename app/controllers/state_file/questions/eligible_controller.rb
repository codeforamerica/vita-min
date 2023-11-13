module StateFile
  module Questions
    class EligibleController < QuestionsController
      private

      def form_class
        NullForm
      end
    end
  end
end