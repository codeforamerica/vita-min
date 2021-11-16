module Hub
  class StateRoutingsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    before_action :load_vita_partners, only: [:edit, :update]
    authorize_resource :state_routing_target
    layout "admin"

    def index
      @state_routings = StateRoutingTarget.joins(:vita_partner).order(state: :asc).all.group_by(&:state).sort
    end

    def edit
      @state = params[:state]
      @form = Hub::StateRoutingForm.new(state: params[:state])
    end

    def update
      @state = params[:state]
      @form = Hub::StateRoutingForm.new(state_routing_params, state: params[:state])
      if @form.valid?
        @form.save
        redirect_to action: :edit
      else
        flash.now[:alert] = I18n.t('general.error.form_failed') if @form.errors.present?
        render :edit
      end
    end

    def destroy
      @state_routing_target = StateRoutingTarget.find_by(state: params[:state], id: params[:id])
      unless @state_routing_target.present?
        flash[:alert] = I18n.t("forms.errors.state_routings.not_found", state: params[:state])
        redirect_to edit_hub_state_routing_path(state: params[:state]) and return
      end

      if @state_routing_target.routing_fraction.zero?
        @state_routing_target.destroy!
      else
        flash[:alert] = I18n.t("forms.errors.state_routings.zero_to_delete")
      end

      redirect_to edit_hub_state_routing_path(state: params[:state])
    end

    def state_routing_params
      params.require(:hub_state_routing_form).permit(state_routing_targets_attributes: {})
    end
  end
end