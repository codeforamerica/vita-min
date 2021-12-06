module Hub
  class CoalitionsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource :coalition, parent: false

    layout "hub"

    def new
      @coalition = Coalition.new
    end

    def create
      @coalition = Coalition.new(coalition_params)
      if @coalition.save
        redirect_to hub_organizations_path
      else
        render :new
      end
    end

    def edit; end

    def update
      if @coalition.update(coalition_params)
        flash[:notice] = I18n.t("general.changes_saved")
        redirect_to edit_hub_coalition_path(id: @coalition.id)
      else
        flash.now[:alert] = I18n.t("general.error.form_failed")
        render :edit
      end
    end

    private

    def coalition_params
      params.require(:coalition).permit(:name, source_parameters_attributes: [:_destroy, :id, :code])
    end
  end
end
