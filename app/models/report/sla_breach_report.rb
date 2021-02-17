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
  def attention_needed_breaches
    @attention_needed_breaches ||= format_hash(data["attention_needed_breaches_by_vita_partner_id"])
  end

  def communication_breaches
    @communication_breaches ||= format_hash(data["communication_breaches_by_vita_partner_id"])
  end

  def interaction_breaches
    @interaction_breaches ||= format_hash(data["interaction_breaches_by_vita_partner_id"])
  end

  def attention_needed_breach_count(vita_partners = nil)
    return data["attention_needed_breach_count"] unless vita_partners.present?

    attention_needed_breaches.slice(*vita_partners.map(&:id)).values.inject(:+) || 0
  end

  def communication_breach_count(vita_partners = nil)
    return data["communication_breach_count"] unless vita_partners.present?

    communication_breaches.slice(*vita_partners.map(&:id)).values.inject(:+) || 0
  end

  def interaction_breach_count(vita_partners = nil)
    return data["interaction_breach_count"] unless vita_partners.present?

    interaction_breaches.slice(*vita_partners.map(&:id)).values.inject(:+) || 0
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
