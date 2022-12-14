module Questions
  class BacktaxesController < QuestionsController
    include AnonymousIntakeConcern
    before_action :load_possible_filing_years, only: [:edit, :update]
    layout "intake"

    private

    def illustration_path
      "calendar.svg"
    end

    def load_possible_filing_years
      @possible_filing_years = MultiTenantService.new(:gyr).filing_years
    end
  end
end
