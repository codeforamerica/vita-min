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
    Client.sla_tracked
      .where(Client.arel_table[:attention_needed_since].lteq(breach_threshold_date))
      .group(:vita_partner_id)
      .count(:id)
  end

  # clients who messaged us and have not been responded to _with a message, call or email_ within the breach threshold
  def outgoing_communication_breaches
    Client.sla_tracked
      .where(Client.arel_table[:first_unanswered_incoming_interaction_at].lteq(breach_threshold_date))
      .group(:vita_partner_id)
      .count(:id)
  end

  # clients who've messaged us _and we've not interacted with their profile at all_ within the breach threshold.
  def outgoing_interaction_breaches
    clients = Client.arel_table
    Client.sla_tracked
      .where(clients[:first_unanswered_incoming_interaction_at].lteq(breach_threshold_date))
      .where(clients[:last_interaction_at].lt(clients[:first_unanswered_incoming_interaction_at]).or(clients[:last_interaction_at].eq(nil)))
      .group(:vita_partner_id)
      .count(:id)
  end
end