module Hub
  class StateRoutingForm < Form
    # include FormAttributes
    attr_accessor :state_routing_target
    attr_accessor :state_routing_targets_attributes
    validate :percentages_must_equal_100
    validate :vita_partners_are_unique

    def initialize(form_params = nil, state:)
      @params = form_params
      @state = state
      @state_routing_targets_attributes = form_params[:state_routing_targets_attributes] if form_params.present?
    end

    def state_routing_targets
      if @state_routing_targets_attributes
        @state_routing_targets_attributes&.values.map do |v|
          routing_fraction = routing_fraction_from_percentage(v[:routing_percentage])
          if v[:id].present?
           vps = StateRoutingTarget.find(v[:id])
           vps.assign_attributes(routing_fraction: routing_fraction)
           vps
          else
            StateRoutingTarget.new(v.except(:routing_percentage).merge(routing_fraction: routing_fraction))
          end
        end
      else
        StateRoutingTarget.where(state: @state).joins(:vita_partner).order(routing_fraction: :desc)
      end
    end

    def state_routing_target
      StateRoutingTarget
    end

    def save
      state_routing_targets_attributes.values.map do |v|
        vps = StateRoutingTarget.find_or_initialize_by(state: @state, vita_partner_id: v[:vita_partner_id])
        vps.update!(routing_fraction: routing_fraction_from_percentage(v[:routing_percentage]))
      end
    end

    private

    def routing_fraction_from_percentage(percentage)
      percentage.to_f / 100
    end

    def percentages_must_equal_100
      sum = 0
      state_routing_targets_attributes.each do |_, v|
        sum += v[:routing_percentage].to_i
      end
      unless sum == 100
        errors.add(:must_equal_100, I18n.t("forms.errors.state_routings.must_equal_100"))
      end
    end

    def vita_partners_are_unique
      vps_ids = state_routing_targets_attributes.values.pluck(:vita_partner_id)
      unless vps_ids.uniq.length == vps_ids.length
        errors.add(:duplicate_vita_partner, I18n.t("forms.errors.state_routings.duplicate_vita_partner"))
      end
    end
  end
end