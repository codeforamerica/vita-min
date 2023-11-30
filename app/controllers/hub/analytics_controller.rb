module Hub
  class AnalyticsController < Hub::BaseController
    before_action :require_admin
    load_and_authorize_resource :client
    load_and_authorize_resource :user, parent: false, only: [:index]
    layout "hub"

    def index
    end
  end
end
