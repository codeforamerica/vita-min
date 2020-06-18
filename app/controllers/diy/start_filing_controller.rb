module Diy
  class StartFilingController < ApplicationController
    before_action :find_diy_intake

    def start
      # nothing left to do!
    end

    def include_analytics?
      true
    end

    def current_diy_intake
      DiyIntake.find_by(token: params[:token])
    end

    private

    def find_diy_intake
      redirect_to diy_file_yourself_path unless current_diy_intake.present?
    end
  end
end