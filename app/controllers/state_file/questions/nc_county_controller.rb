module StateFile
  class Questions::NcCountyController < Questions::QuestionsController
    include ReturnToReviewConcern

    def edit
      @filing_year = Rails.configuration.statefile_current_tax_year
      @counties = current_intake.counties.invert
      super
    end
  end
end
