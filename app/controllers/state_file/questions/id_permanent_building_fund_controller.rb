module StateFile
  module Questions
    class IdPermanentBuildingFundController < QuestionsController
      include ReturnToReviewConcern
      def self.show?(intake)
        intake.has_filing_requirement? && !intake.has_blind_filer?
      end
    end
  end
end
