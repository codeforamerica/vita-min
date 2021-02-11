class SLABreachService
  attr_accessor :report_generated_at
  def initialize
    @report_generated_at = Time.now.utc
  end

  def breach_threshold
    3.business_days.before(@report_generated_at)
  end

  # attention_needed_since is present and is before breach threshold
  # returns data in the format { vita_partner_id: breach_count }
  def attention_needed_breaches
    Client.sla_tracked.group(:vita_partner_id).where(Client.arel_table[:attention_needed_since].lteq(breach_threshold)).count(:id)
  end

  # clients who messaged us and have not been responded to _with a message, call or email_ within the breach threshold
  def outgoing_communication_breaches
    Client.sla_tracked.group(:vita_partner_id).where(Client.arel_table[:first_unanswered_incoming_interaction_at].lteq(breach_threshold)).count(:id)
  end
end