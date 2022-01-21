module Diy
  class TaxSlayerController < ApplicationController
    before_action :redirect_in_offseason, :require_diy_intake

    def show; end

    private

    def redirect_in_offseason
      redirect_to root_path unless open_for_intake?
    end

    def require_diy_intake
      redirect_to diy_file_yourself_path unless session[:diy_intake_id].present?
    end
  end
end
