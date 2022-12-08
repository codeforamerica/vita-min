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
      # TODO(TY2022): Once BacktaxesForm supports 2022, include 2022 in this list
      @possible_filing_years = MultiTenantService.new(:gyr).filing_years
    end
  end
end
