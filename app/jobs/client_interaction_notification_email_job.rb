class ClientInteractionNotificationEmailJob < ApplicationJob
  retry_on Mailgun::CommunicationError

  def perform(interaction, user, **attrs)
    return unless interaction.present? && Flipper.enabled?(:hub_email_notifications)

    # all interactions older than this one or within 10 minutes into the future, ordered oldest to youngest,
    interactions = ClientInteraction.where(
      client: interaction.client,
      interaction_type: interaction.interaction_type
    ).where("created_at <= ?", 10.minutes.from_now(interaction.created_at)).order(created_at: :asc)

    # exit if newer interaction exists, later job will send the message
    return if interactions.empty? || interactions.last.id != interaction.id

    if should_notify?(interaction)
      mail_args_attrs = {
        client: interaction.client,
        user: user,
        received_at: attrs[:received_at] || interaction.created_at,
        interaction_count: interactions.count,
        interaction_type: interaction.interaction_type,
      }

      mail_args_attrs[:is_filing_jointly] = attrs[:is_filing_jointly] if attrs[:is_filing_jointly].present?

      internal_email = InternalEmail.create!(
        mail_class: UserMailer,
        mail_method: :incoming_interaction_notification_email,
        mail_args: ActiveJob::Arguments.serialize(mail_args_attrs)
      )
      mailer_response = internal_email.mail_class.constantize.send(
        internal_email.mail_method,
        **internal_email.deserialized_mail_args
      ).deliver_now
      internal_email.create_outgoing_message_status(
        message_id: mailer_response.message_id,
        message_type: :email
      )
    end

    interactions.destroy_all
  end

  def priority
    PRIORITY_LOW
  end

  private

  def should_notify?(interaction)
    # if notifying about new client message, send email only if client has been unanswered by any user
    return true unless interaction.interaction_type == "new_client_message"
    interaction.client.first_unanswered_incoming_interaction_at.present?
  end
end