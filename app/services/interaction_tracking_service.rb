class InteractionTrackingService
  # As of April 2021, we keep a record of *any* outgoing message to the client (even those that are automated)
  def self.update_last_outgoing_communication_at(client)
    client.touch(:last_outgoing_communication_at)
  end

  # When a client contacts us, update last incoming interaction and last interaction
  def self.record_incoming_interaction(client, set_flag: true, interaction_type:)
    # Do not send notification if the user has opted out of notifications
    # Emails should include the option to opt-out of email notifications
    # Confirm notification respects existing role-based access controls
    # ex: If client is moved out of user’s permissions access, user should get an error message when clicking on client url
    if Flipper.enabled?(:hub_email_notifications)
      users_to_contact = client.assigned_to
      users_to_contact.each do |user|
        next unless user.email_notification_yes?
        internal_email = InternalEmail.create!(
          mail_class: UserMailer,
          mail_method: :incoming_interaction_notification_email,
          mail_args: ActiveJob::Arguments.serialize(
            client: client,
            user: user,
            interaction_type: interaction_type
          )
        )
        SendInternalEmailJob.perform_later(internal_email)
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