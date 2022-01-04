module Hub
  class StateRoutingsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    before_action :load_vita_partners, only: [:edit, :update]
    layout "hub"

    def index
      @state_routings = StateRoutingTarget.order(state_abbreviation: :asc).all.group_by(&:state_abbreviation).sort
    end

    def edit
      @coalition_srts = StateRoutingTarget.where(state_abbreviation: params[:state], target_type: Coalition::TYPE)
      @independent_org_srts = StateRoutingTarget.where(state_abbreviation: params[:state], target_type: VitaPartner::TYPE)
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

    def state_routing_params
      params.require(:hub_state_routing_form).permit(state_routing_fraction_attributes: {})
    end
  end
end