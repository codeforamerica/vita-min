module Hub
  class EfileErrorsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource
    layout "admin"

    def index
      @efile_errors = @efile_errors.order(:source, :code)
    end

    def edit; end

    def show; end

    def update
      if @efile_error.update(permitted_params)
        flash[:notice] = "#{@efile_error.code} updated!"
      else
        flash[:error] = "Could not update #{@efile_error.code}. Try again."
      end
      redirect_to hub_efile_error_path(id: @efile_error.id)
    end

    def permitted_params
      params.require(:efile_error).permit(:expose, :auto_cancel, :auto_wait, :description_en, :description_es, :resolution_en, :resolution_es)
    end
  end
end
