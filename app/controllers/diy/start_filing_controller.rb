module Diy
  class StartFilingController < ApplicationController
    before_action :find_diy_intake
    def start
      # nothing left to do!
    end

    private

    def find_diy_intake
      @intake = DiyIntake.find_by(token: params[:token])
        # redirect_to diy_file_yourself_path unless @intake.present?
    end
  end
end