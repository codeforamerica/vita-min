module StateFile
  module Questions
    class DeclinedTermsAndConditionsController < QuestionsController

      def self.show?(_intake)
        _intake.consented_to_terms_and_conditions_no?
      end
    end
  end
end