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
        { breach_threshold: sla_service.breach_threshold,
          current_as_of: sla_service.report_generated_at,
          breach_counts: sla_service.attention_needed_breach
        }
      end
      data[:total_breaches] = data[:breach_counts].slice(*@vita_partners.map(&:id)).values.inject(:+)
      @attention_needed = OpenStruct.new(data)
    end
  end
end