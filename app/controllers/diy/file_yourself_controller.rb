module Diy
  class FileYourselfController < ApplicationController
    layout "application"
    before_action :redirect_in_offseason

    def edit; end

    private

    def redirect_in_offseason
      redirect_to root_path unless open_for_intake?
    end
  end
end
