module StateFile
  module Questions
    class NjEligibilityHealthInsuranceController < QuestionsController
      include EligibilityOffboardingConcern

      before_action -> { @filing_year = Rails.configuration.statefile_current_tax_year }
    end
  end
end