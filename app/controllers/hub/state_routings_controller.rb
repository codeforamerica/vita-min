module Hub
  class StateRoutingsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    before_action :load_vita_partners, only: [:edit, :update]
    authorize_resource :state_routing_target
    layout "hub"

    def index
      @state_routings = StateRoutingTarget.order(state_abbreviation: :asc).all.group_by(&:state_abbreviation).sort
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
      @vita_partner_state = VitaPartnerState.find_by(state: params[:state], id: params[:id])
      unless @vita_partner_state.present?
        flash[:alert] = I18n.t("forms.errors.state_routings.not_found", state: params[:state])
        redirect_to edit_hub_state_routing_path(state: params[:state]) and return
      end

      if @vita_partner_state.routing_fraction.zero?
        @vita_partner_state.destroy!
      else
        flash[:alert] = I18n.t("forms.errors.state_routings.zero_to_delete")
      end

      redirect_to edit_hub_state_routing_path(state: params[:state])
    end

    def state_routing_params
      params.require(:hub_state_routing_form).permit(vita_partner_states_attributes: {})
    end
  end
end