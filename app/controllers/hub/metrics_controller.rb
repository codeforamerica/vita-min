module Hub
  class MetricsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    layout "hub"
    load_and_authorize_resource :vita_partner, parent: false

    def index
      generated_in_last_10_minutes = Report.arel_table[:generated_at].gteq(10.minutes.ago)
      @report = Report::SLABreachReport.where(generated_in_last_10_minutes).last || Report::SLABreachReport.generate!
      # Recalculate total breaches based on limited vita partner collection if necessary
      @vita_partners = @vita_partners.includes(:organization_capacity)
      limited_partners = @vita_partners unless current_user.admin?
      @total_breaches = {
        unanswered_communication: @report.unanswered_communication_breach_count(limited_partners),
        outgoing_communication: @report.last_outgoing_communication_breach_count(limited_partners),
        interaction: @report.interaction_breach_count(limited_partners),
        total_count: @report.active_sla_clients_count(limited_partners)
      }
    end
  end
end