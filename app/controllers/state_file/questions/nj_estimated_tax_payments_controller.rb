module StateFile
  module Questions
    class NjEstimatedTaxPaymentsController < QuestionsController
      include ReturnToReviewConcern

      before_action -> { @filing_year = Rails.configuration.statefile_current_tax_year }
      before_action -> { @prior_year = Rails.configuration.statefile_current_tax_year - 1 }
    end
  end
end
