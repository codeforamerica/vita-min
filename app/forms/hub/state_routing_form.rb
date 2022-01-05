module Hub
  class StateRoutingForm < Form
    include FormAttributes

    validate :percentages_must_equal_100
    validate :vita_partners_are_unique

    def initialize(form_params = nil, state:)
      @params = form_params
      @state = state
    end

    def save
    end

    private

    def routing_fraction_from_percentage(percentage)
      percentage.to_f / 100
    end

    def percentages_must_equal_100
      # sum = 0
      # vita_partner_states_attributes.each do |_, v|
      #   sum += v[:routing_percentage].to_i
      # end
      # unless sum == 100
      #   errors.add(:must_equal_100, I18n.t("forms.errors.state_routings.must_equal_100"))
      # end
    end

    def vita_partners_are_unique
      # vps_ids = vita_partner_states_attributes.values.pluck(:vita_partner_id)
      # unless vps_ids.uniq.length == vps_ids.length
      #   errors.add(:duplicate_vita_partner, I18n.t("forms.errors.state_routings.duplicate_vita_partner"))
      # end
    end
  end
end