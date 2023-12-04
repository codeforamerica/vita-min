module StateFile
  module Questions
    class DeclinedTermsAndConditionsController < QuestionsController

      def self.show?(_intake)
        false
      end

      private
    end
  end
end