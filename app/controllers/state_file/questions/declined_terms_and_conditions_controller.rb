module StateFile
  module Questions
    class DeclinedTermsAndConditionsController < AuthenticatedQuestionsController

      def self.show?(intake)
        intake.consented_to_terms_and_conditions_no?
      end
    end
  end
end