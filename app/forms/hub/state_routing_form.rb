module Hub
  class StateRoutingForm < Form
    # include FormAttributes
    attr_accessor :vita_partner_state
    attr_accessor :vita_partner_states_attributes
    validate :percentages_must_equal_100
    validate :vita_partners_are_unique

    def initialize(form_params = nil, state:)
      @params = form_params
      @state = state
      @state_routing_fraction_attributes = form_params[:state_routing_fraction_attributes] if form_params.present?
    end

    def state_routing_fractions
      if @state_routing_fraction_attributes
        @state_routing_fraction_attributes&.values&.map do |v|
          routing_fraction = routing_fraction_from_percentage(v[:routing_percentage])
          if v[:id].present?
            srf = StateRoutingFraction.find(v[:id])
            srf.assign_attributes(routing_fraction: routing_fraction)
            srf
          else
            StateRoutingFraction.new(v.except(:routing_percentage).merge(routing_fraction: routing_fraction))
          end
        end
      else
        StateRoutingFraction.where(state: @state).joins(:vita_partner).order(routing_fraction: :desc)
      end
    end

    def save
      state_routing_fraction_attributes.values.map do |v|
        state_routing_target = VitaPartner.find(v[:vita_partner_id])
        srf = StateRoutingFraction.find_or_initialize_by(state_routing_target: @state_routing_target, vita_partner_id: v[:vita_partner_id])
        srf.update!(routing_fraction: routing_fraction_from_percentage(v[:routing_percentage]))
      end
    end

    private

    def routing_fraction_from_percentage(percentage)
      percentage.to_f / 100
    end

    def percentages_must_equal_100
      sum = 0
      vita_partner_states_attributes.each do |_, v|
        sum += v[:routing_percentage].to_i
      end
      unless sum == 100
        errors.add(:must_equal_100, I18n.t("forms.errors.state_routings.must_equal_100"))
      end
    end

    def vita_partners_are_unique
      vps_ids = vita_partner_states_attributes.values.pluck(:vita_partner_id)
      unless vps_ids.uniq.length == vps_ids.length
        errors.add(:duplicate_vita_partner, I18n.t("forms.errors.state_routings.duplicate_vita_partner"))
      end
    end
  end
end