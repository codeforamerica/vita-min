module StateFile
  module Questions
    class CodeVerifiedController < QuestionsController

      def edit
        # Doing updates in an edit feels really icky.
        # binding.pry
        # If it is valid
        #   Is there an existing intake with the same contact details? Use that id instead...
        super
      end

      private

      def form_class
        NullForm
      end
    end
  end
end