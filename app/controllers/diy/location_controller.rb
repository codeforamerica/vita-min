module Diy
  class LocationController < DiyController
    skip_before_action :require_diy_intake

    layout "application"

    def form_class
      DiyLocationForm
    end

  end
end