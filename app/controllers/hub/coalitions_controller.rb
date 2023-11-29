module Hub
  class CoalitionsController < Hub::BaseController
    load_and_authorize_resource :coalition, parent: false

    layout "hub"

    def new; end

    def create
      @form = CoalitionForm.new(@coalition, states: state_routing_target_params[:states], name: coalition_params[:name])
      if @form.save
        redirect_to hub_organizations_path
      else
        render :new
      end
    end

    def edit; end

    def update
      @form = CoalitionForm.new(@coalition, states: state_routing_target_params[:states], name: coalition_params[:name])
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
      params.require(:coalition).permit(:name)
    end

    def state_routing_target_params
      params.require(:state_routing_targets).permit(:states)
    end
  end
end
