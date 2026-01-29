module Diy
  class BaseController < ApplicationController
    before_action :redirect_in_offseason

    helper_method :current_path #,  :illustration_folder, :illustration_path, :next_path, :prev_path, :has_unsure_option?, :method_name, :form_name

    private

    def redirect_in_offseason
      redirect_to root_path unless open_for_diy?
    end
  end
end
