module Hub
  class StateRoutingsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    before_action :load_state_and_routing_targets, :load_independent_organizations, only: [:edit, :update, :add_organizations]
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

    def add_organizations
      vita_partner_ids = JSON.parse(add_organizations_params).map { |vita_partner| vita_partner["id"] }
      vita_partner_ids.each do |id|
        StateRoutingTarget.create(target_id: id, target_type: VitaPartner.name, state_abbreviation: @state)
      end
      redirect_to action: :edit
    end

    private

    def add_organizations_params
      params.require(:vita_partners)
    end

    def state_routing_params
      params.require(:hub_state_routing_form).permit(state_routing_fraction_attributes: {})
    end

    def load_state_and_routing_targets
      @state = params[:state]
      @coalition_srts = StateRoutingTarget.where(state_abbreviation: @state, target_type: Coalition.name).includes(:state_routing_fractions)
      @independent_org_srts = StateRoutingTarget.where(state_abbreviation: @state, target_type: VitaPartner.name).includes(:state_routing_fractions)
    end

    def load_independent_organizations
      @independent_organizations = Organization.where(coalition: nil).where.not(id: @independent_org_srts.pluck(:target_id))
    end
  end
end