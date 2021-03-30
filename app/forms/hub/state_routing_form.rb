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
      @vita_partner_states_attributes = form_params[:vita_partner_states_attributes] if form_params.present?
    end

    def vita_partner_states
      if @vita_partner_states_attributes
        @vita_partner_states_attributes&.values.map do |v|
          routing_fraction = routing_fraction_from_percentage(v.delete([:routing_percentage]))
          if v[:id].present?
           vps = VitaPartnerState.find(v[:id])
           vps.assign_attributes(routing_fraction: routing_fraction)
           vps
          else
            VitaPartnerState.new(v.merge(routing_fraction: routing_fraction))
          end
        end
      else
        VitaPartnerState.where(state: @state).joins(:vita_partner).order(routing_fraction: :desc)
      end
    end

    def vita_partner_state
      VitaPartnerState
    end

    def save
      vita_partner_states_attributes.values.map do |v|
        vps = VitaPartnerState.find_or_initialize_by(state: @state, vita_partner_id: v[:vita_partner_id])
        vps.update!(routing_fraction: routing_fraction_from_percentage(v[:routing_percentage]))
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