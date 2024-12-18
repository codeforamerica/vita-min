module StateFile
  module Questions
    class EligibleController < QuestionsController
      include OtherOptionsLinksConcern

      private

      def form_class
        NullForm
      end
    end
  end
end