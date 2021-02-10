class SLABreachService
  attr_accessor :report_generated_at
  def initialize
    @report_generated_at = DateTime.current
  end

  def breach_threshold
    3.business_days.before(@report_generated_at)
  end

  # attention_needed_since is present and is before breach threshold
  # returns data in the format { vita_partner_id: breach_count }
  def attention_needed_breach
    Client.sla_tracked.group(:vita_partner_id).where(Client.arel_table[:attention_needed_since].lteq(breach_threshold)).count(:id)
  end
end