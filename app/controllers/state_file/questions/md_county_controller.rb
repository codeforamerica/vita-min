module StateFile
  class Questions::MdCountyController < Questions::QuestionsController
    include ReturnToReviewConcern
    before_action :set_ivars, only: [:edit, :update]

    def set_ivars
      @filing_year = Rails.configuration.statefile_current_tax_year
      @counties = current_intake.counties_for_select
    end
  end
end
