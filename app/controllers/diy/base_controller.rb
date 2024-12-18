module Diy
  class BaseController < ApplicationController
    before_action :redirect_in_offseason

    private

    def redirect_in_offseason
      redirect_to root_path unless open_for_diy?
    end
  end
end
