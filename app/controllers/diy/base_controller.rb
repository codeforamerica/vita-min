module Diy
  class BaseController < ApplicationController
    before_action :redirect_in_offseason

    def current_diy_intake
      if session[:diy_intake_id]
        DiyIntake.find(session[:diy_intake_id])
      else
        DiyIntake.new(preferred_first_name: "temp")
      end
    end

    private

    def redirect_in_offseason
      redirect_to root_path unless open_for_diy?
    end
  end
end
