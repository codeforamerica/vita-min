module StateFile
  module Questions
    class AzTaxesOwedController < QuestionsController
      def edit; end

      private

      def form_class
        NullForm
      end
    end
  end
end
