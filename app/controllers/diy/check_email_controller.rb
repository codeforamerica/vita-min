module Diy
  class CheckEmailController < DiyController
    layout "application"
    append_after_action :reset_session, :track_page_view

    def form_class
      DiyForm
    end
  end
end
