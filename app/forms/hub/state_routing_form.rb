module Hub
  class StateRoutingForm < Form
    include FormAttributes

    validate :percentages_must_equal_100

    def initialize(form_params = nil)
      @form_params = form_params
    end

    def save
      state_routing_fraction_attributes.each do |vita_partner_id, v|
        existing_fraction = StateRoutingFraction.where(vita_partner_id: vita_partner_id, state_routing_target_id: v[:state_routing_target_id]).first
        if existing_fraction.present?
          existing_fraction.update(routing_fraction: routing_fraction_from_percentage(v[:routing_percentage]))
        else
          StateRoutingFraction.create(state_routing_target_id: v[:state_routing_target_id],
                                      vita_partner_id: vita_partner_id,
                                      routing_fraction: routing_fraction_from_percentage(v[:routing_percentage]))
        end
      end
    end

    private

    def routing_fraction_from_percentage(percentage)
      percentage.to_f / 100
    end

    def percentages_must_equal_100
      sum = 0
      state_routing_fraction_attributes.each do |_, v|
        sum += v[:routing_percentage].to_i
      end
      unless sum == 100
        errors.add(:must_equal_100, I18n.t("forms.errors.state_routings.must_equal_100"))
      end
    end

    def state_routing_fraction_attributes
      @form_params.present? ? @form_params[:state_routing_fraction_attributes] : {}
    end
  end
end