module StateFile
  module Questions
    class NjUnsupportedPropertyTaxController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        intake.household_rent_own_both?
      end
    end
  end
end

