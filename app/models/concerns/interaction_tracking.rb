module InteractionTracking
  extend ActiveSupport::Concern

  # When a client contacts us, update last incoming interaction and last interaction
  # Only update attention_needed_since if the client did not already need attention.
  def record_incoming_interaction
    touches = [:last_incoming_interaction_at]
    touches.push(:first_unanswered_incoming_interaction_at) unless client.first_unanswered_incoming_interaction_at.present?
    touches.push(:attention_needed_since) unless client.attention_needed_since.present?
    client&.touch(*touches)
  end

  # When we contact a client, update our last touch to them for SLA purposes and clear the attention flag
  def record_outgoing_interaction
    client&.update(
      last_internal_or_outgoing_interaction_at: Time.now.to_datetime,
      attention_needed_since: nil,
      first_unanswered_incoming_interaction_at: nil, # we've explicitly responded to them somehow, so we can clear this value.
    )
  end

  # "Internal" interactions do not clear needs_attention_since
  def record_internal_interaction
    client&.touch(:last_internal_or_outgoing_interaction_at)
  end
end