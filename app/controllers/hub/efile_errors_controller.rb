module Hub
  class EfileErrorsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource
    layout "admin"

    def index; end

    def edit; end

    def update
      if @efile_error.update(permitted_params)
        flash[:notice] = "#{@efile_error.code} updated!"
      else
        flash[:error] = "Could not update #{@efile_error.code}. Try again."
      end
      redirect_to hub_efile_errors_path
    end

    def permitted_params
      params.require(:efile_error).permit(:expose)
    end
  end
end