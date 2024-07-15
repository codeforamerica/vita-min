module StateFile
  module Questions
    class EligibleController < AuthenticatedQuestionsController
      include OtherOptionsLinksConcern

      private

      def form_class
        NullForm
      end
    end
  end
end