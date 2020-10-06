class ZendeskWebhookController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :authenticate_zendesk_request

  def incoming
    case json_payload[:method]
    when "updated_sms"
      incoming_sms
    when "updated_ticket"
      updated_ticket
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
    ) if valid_phone_number?
  end

  def updated_ticket
    UpdateZendeskTicketStatusJob.perform_later(json_payload.permit!)
  end

  private

  def valid_phone_number?
    Phonelib.valid?(json_payload["requester_phone_number"])
  end

  def json_payload
    params[:zendesk_webhook]
  end

  def authenticate_zendesk_request
    authenticate_or_request_with_http_basic do |name, password|
      expected_name = EnvironmentCredentials.dig(:zendesk_webhook_auth, :name)
      expected_password = EnvironmentCredentials.dig(:zendesk_webhook_auth, :password)
      ActiveSupport::SecurityUtils.secure_compare(name, expected_name) &&
        ActiveSupport::SecurityUtils.secure_compare(password, expected_password)
    end
  end
end
