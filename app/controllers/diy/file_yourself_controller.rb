module Diy
  class FileYourselfController < DiyController
    skip_before_action :require_diy_intake

    layout "application"

    def edit; end
  end
end
