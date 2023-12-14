module Hub
  class StateFileController < Hub::BaseController
    #load_and_authorize_resource
    layout "hub"
    before_action :require_state_file

    def index
    end
  end
end