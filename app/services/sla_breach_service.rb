class SLABreachService
  attr_accessor :report_generated_at

  def initialize
    @report_generated_at = Time.now.utc
  end

  def breach_threshold_date
    3.business_days.before(@report_generated_at)
  end

  def active_sla_clients_count
    count_by_vita_partner(Client.sla_tracked)
  end

  # flagged_at is present and is before breach threshold
  # returns data in the format { vita_partner_id: breach_count }
  def response_needed_breaches
    count_by_vita_partner(Client.response_needed_breaches(breach_threshold_date))
  end

  # clients who messaged us and have not been responded to _with a message, call or email_ within the breach threshold
  def first_unanswered_incoming_interaction_communication_breaches
    count_by_vita_partner(Client.first_unanswered_incoming_interaction_communication_breaches(breach_threshold_date))
  end

  def last_outgoing_communication_breaches
    count_by_vita_partner(Client.last_outgoing_communication_breaches(breach_threshold_date))
  end

  # clients who've messaged us _and we've not interacted with their profile at all_ within the breach threshold.
  def outgoing_interaction_breaches
    count_by_vita_partner(Client.outgoing_interaction_breaches(breach_threshold_date))
  end

  def self.generate_report
    report = SLABreachService.new
    communication_breaches = report.first_unanswered_incoming_interaction_communication_breaches
    last_outgoing_communication_breaches = report.last_outgoing_communication_breaches
    interaction_breaches = report.outgoing_interaction_breaches
    response_breaches = report.response_needed_breaches
    active_sla_clients = report.active_sla_clients_count
    {
        breached_at: report.breach_threshold_date,
        generated_at: report.report_generated_at,
        active_sla_clients_by_vita_partner_id: active_sla_clients,
        active_sla_clients_count: active_sla_clients.values.sum,
        response_needed_breaches_by_vita_partner_id: response_breaches,
        response_needed_breach_count: response_breaches.values.sum,
        communication_breaches_by_vita_partner_id: communication_breaches,
        communication_breach_count: communication_breaches.values.sum,
        last_outgoing_communication_breaches_by_vita_partner_id: last_outgoing_communication_breaches,
        last_outgoing_communication_breach_count: last_outgoing_communication_breaches.values.sum,
        interaction_breaches_by_vita_partner_id: interaction_breaches,
        interaction_breach_count: interaction_breaches.values.sum,
    }
  end

  private

  def count_by_vita_partner(client_relation)
    client_relation.group(:vita_partner_id).count(:id)
  end
end