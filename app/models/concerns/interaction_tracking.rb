module InteractionTracking
  extend ActiveSupport::Concern

  # When a client contacts us, flag client for attention and update last incoming response.
  def record_incoming_interaction
    client&.touch(:response_needed_since, :last_incoming_interaction_at, :last_interaction_at)
  end

  # When we contact a client, update our last touch to them for SLA purposes and clear the attention flag
  def record_outgoing_interaction
    client&.update(last_interaction_at: Time.now.to_datetime, response_needed_since: nil)
  end

  # When we take an "internal" action on a client (i.e. write a note, we want to update our last touch but NOT alter the attention flag)
  def record_internal_interaction
    client&.touch(:last_interaction_at)
  end
end