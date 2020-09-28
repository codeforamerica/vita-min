module Diy
  class CheckEmailController < DiyController
    layout "application"
    skip_before_action :require_diy_intake
    append_after_action :reset_session, :track_page_view

    def form_class
      DiyForm
    end
  end
end
