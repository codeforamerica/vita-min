class MailgunWebhooksController < ApplicationController
  skip_before_action :redirect_to_getyourrefund
  skip_before_action :set_visitor_id
  skip_before_action :set_source
  skip_before_action :set_referrer
  skip_before_action :set_utm_state
  skip_before_action :set_sentry_context
  skip_before_action :check_maintenance_mode
  skip_after_action :track_page_view
  skip_before_action :verify_authenticity_token
  before_action :valid_mailgun_post?

  def create_incoming_email
    sender_email = params["sender"]
    client = Client.where(email_address: sender_email).first
    unless client.present?
      client = Client.create!(email_address: sender_email)
    end
    IncomingEmail.create!(
      client: client,
      received_at: DateTime.now,
      sender: sender_email,
      to: params["To"],
      from: params["From"],
      recipient: params["recipient"],
      subject: params["subject"],
      body_html: params["body-html"],
      body_plain: params["body-plain"],
      stripped_html: params["stripped-html"],
      stripped_text: params["stripped-text"],
      stripped_signature: params["stripped-signature"],
      received: params["Received"],
      attachment_count: params["attachment-count"],
    )
    head :ok
  end

  private

  def valid_mailgun_post?
    return head 403 unless MailgunService.valid_post?(params)
  end
end