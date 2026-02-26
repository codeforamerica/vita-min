module Hub
  class AnalyticsController < Hub::BaseController
    before_action :require_admin

    def show
    end
  end
end
