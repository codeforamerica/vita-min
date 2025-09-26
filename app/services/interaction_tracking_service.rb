class InteractionTrackingService
  # As of April 2021, we keep a record of *any* outgoing message to the client (even those that are automated)
  def self.update_last_outgoing_communication_at(client)
    client.touch(:last_outgoing_communication_at)
  end

  def self.record_incoming_interaction(client, set_flag: true, **attrs)
    # sends email notification to assigned users when client has sent an email, sms or portal message
    interaction_type = attrs[:interaction_type]
    should_record_interaction = interaction_type.present? && interaction_type != 'unfilled'
    if should_record_interaction && Flipper.enabled?(:hub_email_notifications)
      users_to_contact = client.tax_returns.pluck(:assigned_user_id).compact
      users_to_contact = User.where(id: users_to_contact, "#{interaction_type}_notification" => "yes")
      unless users_to_contact.empty?
        email_attrs = {
          received_at: attrs[:received_at] || interaction.created_at
        }
        email_attrs[:is_filing_jointly] = attrs[:is_filing_jointly] if attrs[:is_filing_jointly].present?

        users_to_contact.each do |user|
          interaction = ClientInteraction.create!(client: client, interaction_type: interaction_type)
          ClientInteractionNotificationEmailJob.set(wait: 10.minutes).perform_later(interaction, user, **email_attrs) unless client.has_archived_intake?
        end
      end
    end

    # updates last interaction
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
  def self.record_internal_interaction(client, **attrs)
    interaction_type = attrs[:interaction_type]

    if interaction_type == "tagged_in_note"
      user = attrs[:user]
      if user&.tagged_in_note_notification_yes? && Flipper.enabled?(:hub_email_notifications)
        internal_email = InternalEmail.create!(
          mail_class: UserMailer,
          mail_method: :internal_interaction_notification_email,
          mail_args: ActiveJob::Arguments.serialize(
            client: client,
            user: user,
            received_at: attrs[:received_at],
            interaction_type: interaction_type,
          )
        )
        SendInternalEmailJob.perform_later(internal_email) unless client.has_archived_intake?
      end
    end

    client&.touch(:last_internal_or_outgoing_interaction_at)
  end
end