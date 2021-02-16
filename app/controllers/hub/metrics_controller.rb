module Hub
  class MetricsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    layout "admin"
    load_and_authorize_resource :vita_partner, parent: false

    def index
      # Run SLA queries and cache the result for 10 minutes.
      # The view will only display values for vita partners the user has access to view.
      data = Rails.cache.fetch("metrics/sla_breaches/attention_needed", expires_in: 10.minutes) do
        sla_service = SLABreachService.new
        attention_needed_breaches = sla_service.attention_needed_breaches
        outgoing_communication_breaches = sla_service.outgoing_communication_breaches
        outgoing_interaction_breaches = sla_service.outgoing_interaction_breaches
        {
          breach_threshold_date: sla_service.breach_threshold_date,
          current_as_of: sla_service.report_generated_at,
          attention_needed_breaches_by_vita_partner: attention_needed_breaches,
          communication_breaches_by_vita_partner: outgoing_communication_breaches,
          interaction_breaches_by_vita_partner: outgoing_interaction_breaches,
          attention_needed_breach_count: attention_needed_breaches.values.inject(:+),
          communication_breach_count: outgoing_communication_breaches.values.inject(:+),
          interaction_breach_count: outgoing_interaction_breaches.values.inject(:+)
        }
      end

      # We need to sum these values for the vita_partners the current user has access to.
      # Admin has access to all vita partners, the values for which we cache, so we don't need to recalculate.
      unless current_user.admin?
        data[:attention_needed_breach_count] = data[:attention_needed_breaches_by_vita_partner].slice(*@vita_partners.map(&:id)).values.inject(:+)
        data[:communication_breach_count] = data[:communication_breaches_by_vita_partner].slice(*@vita_partners.map(&:id)).values.inject(:+)
        data[:interaction_breach_count] = data[:interaction_breaches_by_vita_partner].slice(*@vita_partners.map(&:id)).values.inject(:+)
      end

      # Cast UTC stored data in the cache to the current_user's timezone.
      data[:breach_threshold_date] = data[:breach_threshold_date].in_time_zone(current_user.timezone)
      data[:current_as_of] = data[:current_as_of].in_time_zone(current_user.timezone)
      @breach_data = OpenStruct.new(data)
    end
  end
end