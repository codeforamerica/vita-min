class SLABreachService
  attr_accessor :report_generated_at

  def initialize
    @report_generated_at = Time.now.utc
  end

  def breach_threshold_date
    3.business_days.before(@report_generated_at)
  end

  # attention_needed_since is present and is before breach threshold
  # returns data in the format { vita_partner_id: breach_count }
  def attention_needed_breaches
    Client.attention_needed_breaches(breach_threshold_date).group(:vita_partner_id).count(:id)
  end

  # clients who messaged us and have not been responded to _with a message, call or email_ within the breach threshold
  def outgoing_communication_breaches
    Client.outgoing_communication_breaches(breach_threshold_date).group(:vita_partner_id).count(:id)
  end

  # clients who've messaged us _and we've not interacted with their profile at all_ within the breach threshold.
  def outgoing_interaction_breaches
    Client.outgoing_interaction_breaches(breach_threshold_date).group(:vita_partner_id).count(:id)
  end

  def self.generate_report
    report = SLABreachService.new
    communication_breaches = report.outgoing_communication_breaches
    interaction_breaches = report.outgoing_interaction_breaches
    attention_breaches = report.attention_needed_breaches
    {
        breached_at: report.breach_threshold_date,
        generated_at: report.report_generated_at,
        attention_needed_breaches_by_vita_partner_id: attention_breaches,
        attention_needed_breach_count: attention_breaches.values.inject(:+) || 0,
        communication_breaches_by_vita_partner_id: communication_breaches,
        communication_breach_count: communication_breaches.values.inject(:+) || 0,
        interaction_breaches_by_vita_partner_id: interaction_breaches,
        interaction_breach_count: interaction_breaches.values.inject(:+) || 0,
    }
  end
end