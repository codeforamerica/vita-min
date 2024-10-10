module StateFile
  module Questions
    class NjIneligiblePropertyTaxController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        intake.household_rent_own == 'neither'
      end
    end
  end
end

