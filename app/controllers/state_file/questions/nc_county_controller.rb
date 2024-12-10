module StateFile
  class Questions::NcCountyController < Questions::QuestionsController
    include ReturnToReviewConcern
    before_action :set_ivars, only: [:edit, :update]

    def set_ivars
      @counties = current_intake.counties_for_select
      @designated_hurricane_relief_counties = NcResidenceCountyConcern.designated_hurricane_relief_counties
    end
  end
end
