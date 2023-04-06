class SLABreachService
  attr_accessor :report_generated_at

  def initialize
    @report_generated_at = Time.now.utc
  end

  def breach_threshold_date
    6.business_days.before(@report_generated_at)
  end

  def active_sla_clients_count
    count_by_vita_partner(Client.sla_tracked)
  end

  def last_outgoing_communication_breaches
    count_by_vita_partner(Client.where("last_outgoing_communication_at < ?", breach_threshold_date))
  end

  def self.generate_report
    report = SLABreachService.new
    communication_breaches = report.last_outgoing_communication_breaches
    active_sla_clients = report.active_sla_clients_count
    {
        breached_at: report.breach_threshold_date,
        generated_at: report.report_generated_at,
        active_sla_clients_by_vita_partner_id: active_sla_clients,
        active_sla_clients_count: active_sla_clients.values.sum,
        communication_breaches_by_vita_partner_id: communication_breaches,
        communication_breach_count: communication_breaches.values.sum,
    }
  end

  private

  def count_by_vita_partner(client_relation)
    client_relation.group(:vita_partner_id).count(:id)
  end
end
