class ZendeskWebhookController < ApplicationController
  skip_before_action :verify_authenticity_token, :set_visitor_id, :set_source, :set_referrer, :set_utm_state
  before_action :authenticate

  def incoming
    if ["new_sms", "updated_sms"].include? json_payload[:method]
      incoming_sms
    end
    head :ok if params[:zendesk_webhook].present?
  end

  def incoming_sms
    phone_number = json_payload["requester_phone_number"].tr("+", "")
    sms_ticket_id = json_payload["ticket_id"].to_i
    message_body = json_payload["message_body"]

    ZendeskInboundSmsJob.perform_later(
      sms_ticket_id: sms_ticket_id,
      phone_number: phone_number,
      message_body: message_body
    )
  end

  private

  def json_payload
    params[:zendesk_webhook]
  end

  def authenticate
    authenticate_or_request_with_http_basic do |name, password|
      expected_name = EnvironmentCredentials.dig(:zendesk_webhook_auth, :name)
      expected_password = EnvironmentCredentials.dig(:zendesk_webhook_auth, :password)
      ActiveSupport::SecurityUtils.secure_compare(name, expected_name) &&
        ActiveSupport::SecurityUtils.secure_compare(password, expected_password)
    end
  end
end
