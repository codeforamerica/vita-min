module Hub
  class AiScreenerMetricsController < Hub::BaseController
    before_action :require_admin

    def show
      @metrics = AiScreenerMetricsService.new.call
    end
  end
end