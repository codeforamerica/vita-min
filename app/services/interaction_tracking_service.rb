class InteractionTrackingService
  # As of April 2021, we keep a record of *any* outgoing message to the client (even those that are automated)
  def self.update_last_outgoing_communication_at(client)
    client.touch(:last_outgoing_communication_at)
  end

  # When a client contacts us, update last incoming interaction and last interaction
  def self.record_incoming_interaction(client)
    touches = [:last_incoming_interaction_at]
    touches.push(:first_unanswered_incoming_interaction_at) unless client.first_unanswered_incoming_interaction_at.present?
    client&.touch(*touches)
  end

  # When we contact a client, update our last touch to them for SLA purposes
  def self.record_user_initiated_outgoing_interaction(client)
    client&.update!(
      last_internal_or_outgoing_interaction_at: Time.now,
      first_unanswered_incoming_interaction_at: nil, # we've explicitly responded to them somehow, so we can clear this value.
    )
  end

  # "Internal" interactions
  def self.record_internal_interaction(client)
    client&.touch(:last_internal_or_outgoing_interaction_at)
  end
end