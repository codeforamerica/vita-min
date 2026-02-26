module Hub
  class AiScreenerMetricsController < Hub::BaseController
    before_action :require_admin

    def show
      @ai_accuracy = Document
    end
  end
end
