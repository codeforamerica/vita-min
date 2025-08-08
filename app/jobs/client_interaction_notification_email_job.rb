class ClientInteractionNotificationEmailJob < ApplicationJob
  retry_on Mailgun::CommunicationError

  def perform(internal_email, interaction)
    return unless interaction.present? && Flipper.enabled?(:hub_email_notifications)
    interactions = ClientInteraction.where(
      client: interaction.client,
      interaction_type: interaction.interaction_type
    ).where("created_at > ?", 10.minutes.ago(interaction.created_at)).order(created_at: :asc)
    return if interactions.empty?

    window_start = interactions.first.created_at
    window_end = window_start + 10.minutes
    interactions_in_window = interactions.where(created_at: window_start..window_end)
    # exit if newer interaction exists, later job will send the message
    return unless interactions_in_window.last == interaction

    if interaction.client.first_unanswered_incoming_interaction_at.present?
      # send email only if client has been unanswered by a user
      mailer_response = internal_email.mail_class.constantize.send(internal_email.mail_method, **internal_email.deserialized_mail_args).deliver_now
      internal_email.create_outgoing_message_status(message_id: mailer_response.message_id, message_type: :email)
    end

    interactions_in_window.destroy_all
  end

  def priority
    PRIORITY_LOW
  end
end