module Diy
  class TaxSlayerController < ApplicationController
    before_action :require_diy_intake

    def show; end

    private

    def require_diy_intake
      redirect_to diy_file_yourself_path unless session[:diy_intake_id].present?
    end
  end
end