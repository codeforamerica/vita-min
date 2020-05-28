module Diy
  class StartFilingController < ApplicationController
    before_action :find_diy_intake

    def start
      # nothing left to do!
    end

    def include_google_analytics?
      true
    end

    private

    def find_diy_intake
      redirect_to diy_file_yourself_path unless DiyIntake.find_by(token: params[:token]).present?
    end
  end
end