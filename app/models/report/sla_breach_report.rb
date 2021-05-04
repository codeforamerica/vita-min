# == Schema Information
#
# Table name: reports
#
#  id           :bigint           not null, primary key
#  data         :jsonb
#  generated_at :datetime
#  type         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_reports_on_generated_at  (generated_at)
#
class Report::SLABreachReport < Report
  def self.generate!
    data = SLABreachService.generate_report
    generated_at = data.delete(:generated_at)
    create!(data: data, generated_at: generated_at)
  end

  # JSON keys must be strings, but we need vita_partner id keys to be integers
  def response_needed_breaches
    @response_needed_breaches ||= format_hash(data["response_needed_breaches_by_vita_partner_id"])
  end

  def communication_breaches
    @communication_breaches ||= format_hash(data["communication_breaches_by_vita_partner_id"])
  end

  def last_outgoing_communication_breaches
    @last_outgoing_communication_breaches ||= format_hash(data["last_outgoing_communication_breaches_by_vita_partner_id"])
  end

  def interaction_breaches
    @interaction_breaches ||= format_hash(data["interaction_breaches_by_vita_partner_id"])
  end

  def active_sla_clients
    @active_sla_clients ||= format_hash(data["active_sla_clients_by_vita_partner_id"])
  end

  def response_needed_breach_count(vita_partners = nil)
    return data["response_needed_breach_count"] unless vita_partners.present?

    response_needed_breaches.slice(*vita_partners.map(&:id)).values.sum
  end

  def communication_breach_count(vita_partners = nil)
    return data["communication_breach_count"] unless vita_partners.present?

    communication_breaches.slice(*vita_partners.map(&:id)).values.sum
  end

  def last_outgoing_communication_breach_count(vita_partners = nil)
    return data["last_outgoing_communication_breach_count"] unless vita_partners.present?

    communication_breaches.slice(*vita_partners.map(&:id)).values.sum
  end

  def interaction_breach_count(vita_partners = nil)
    return data["interaction_breach_count"] unless vita_partners.present?

    interaction_breaches.slice(*vita_partners.map(&:id)).values.sum
  end

  def active_sla_clients_count(vita_partners = nil)
    return data["active_sla_clients_count"] unless vita_partners.present?

    active_sla_clients.slice(*vita_partners.map(&:id)).values.sum
  end


  def breached_at
    @breached_at ||= data["breached_at"].in_time_zone
  end

  private

  # Convert string keys to integers, and set default value
  def format_hash(hash)
    hash = Hash[hash.keys.map(&:to_i).zip(hash.values)]
    hash.default = 0
    hash
  end
end
