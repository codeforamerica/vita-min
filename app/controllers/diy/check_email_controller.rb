module Diy
  class CheckEmailController < DiyController
    layout "application"

    def form_class
      DiyForm
    end
  end
end
