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
      @form = CoalitionForm.new(@coalition, coalition_params.merge(state_routing_target_params))
      if @form.save
        redirect_to hub_organizations_path
      else
        render :new
      end
    end

    def edit; end

    def update
      @form = CoalitionForm.new(@coalition, coalition_params.merge(state_routing_target_params))
      if @form.save
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

    def state_routing_target_params
      params.require(:state_routing_targets).permit(:states)
    end
  end
end
