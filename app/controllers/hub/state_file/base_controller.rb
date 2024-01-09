module Hub
  module StateFile
    class Hub::StateFile::BaseController < Hub::BaseController
      before_action :require_state_file
      layout "hub"

    end
  end
end