class InteractionTrackingService
  # As of April 2021, we keep a record of *any* outgoing message to the client (even those that are automated)
  def self.update_last_outgoing_communication_at(client)
    client.touch(:last_outgoing_communication_at)
  end

  # When a client contacts us, update last incoming & last interaction and send a email notification to assigned users
  def self.record_incoming_interaction(client, set_flag: true, message_received_at: nil)
    if message_received_at.present? && Flipper.enabled?(:hub_email_notifications)
      users_to_contact = client.tax_returns.pluck(:assigned_user_id).compact
      unless users_to_contact.empty?
        users_to_contact.each do |user_id|
          user = User.find(user_id)
          next unless user && user.email_notification == "yes"
          internal_email = InternalEmail.create!(
            mail_class: UserMailer,
            mail_method: :incoming_interaction_notification_email,
            mail_args: ActiveJob::Arguments.serialize(
              client: client,
              user: user,
              message_received_at: message_received_at,
            )
          )
          SendInternalEmailJob.perform_later(internal_email)
        end
      end
    end

    touches = [:last_incoming_interaction_at]
    touches.push(:first_unanswered_incoming_interaction_at) unless client.first_unanswered_incoming_interaction_at.present?
    touches.push(:flagged_at) if set_flag && !client.flagged?
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