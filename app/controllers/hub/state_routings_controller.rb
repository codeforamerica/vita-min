module Hub
  class StateRoutingsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    before_action :load_state_and_routing_targets, only: [:edit, :update]
    authorize_resource :state_routing_target
    layout "hub"

    def index
      @state_routings = StateRoutingTarget.order(state_abbreviation: :asc).all.group_by(&:state_abbreviation).sort
    end

    def edit
      @form = Hub::StateRoutingForm.new
    end

    def update
      @form = Hub::StateRoutingForm.new(state_routing_params)
      if @form.valid?
        @form.save
        redirect_to action: :edit
      else
        flash.now[:alert] = I18n.t('general.error.form_failed') if @form.errors.present?
        render :edit
      end
    end

    private

    def state_routing_params
      params.require(:hub_state_routing_form).permit(state_routing_fraction_attributes: {})
    end

    def load_state_and_routing_targets
      @state = params[:state]
      @coalition_srts = StateRoutingTarget.where(state_abbreviation: @state, target_type: Coalition.name).includes(:state_routing_fractions)
      @independent_org_srts = StateRoutingTarget.where(state_abbreviation: @state, target_type: VitaPartner.name).includes(:state_routing_fractions)
    end
  end
end