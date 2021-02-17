module Hub
  class MetricsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    layout "admin"
    load_and_authorize_resource :vita_partner, parent: false

    def index
      generated_in_last_10_minutes = Report.arel_table[:generated_at].gteq(10.minutes.ago)
      @report = Report::SLABreachReport.where(generated_in_last_10_minutes).last || Report::SLABreachReport.generate!
      # Recalculate total breaches based on limited vita partner collection if necessary
      limited_partners = @vita_partners unless current_user.admin?
      @total_breaches = {
        attention_needed: @report.attention_needed_breach_count(limited_partners),
        communication: @report.communication_breach_count(limited_partners),
        interaction: @report.interaction_breach_count(limited_partners)
      }
    end
  end
end