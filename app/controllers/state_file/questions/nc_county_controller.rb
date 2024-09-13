module StateFile
  class Questions::NcCountyController < Questions::QuestionsController
    include ReturnToReviewConcern

    before_action -> { @filing_year = Rails.configuration.statefile_current_tax_year }

    def edit
      @counties = current_intake.counties.invert
      super
    end
  end
end
