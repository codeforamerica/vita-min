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
    )
  end

  def updated_ticket
    return unless has_valid_intake_id? && intakes_for_ticket.present?

    # in rare cases, there may be multiple intakes with the same ticket id
    intakes_for_ticket.each do |intake|
      current_status = intake.current_ticket_status
      if current_status.nil? || ticket_status_changed?(current_status, incoming_ticket_statuses)
        # verified_change means that we already had an old TicketStatus in the database and it had
        # different status data.
        verified_change = !current_status.nil?
        new_status = intake.ticket_statuses.create(ticket_id: json_payload[:ticket_id], verified_change: verified_change, **incoming_ticket_statuses)
      end

      if new_status&.verified_change?
        new_status.send_mixpanel_event(mixpanel_routing_data)
      end
    end
  end

  private

  def ticket_status_changed?(current_status, intake_status: nil, return_status: nil, eip_status: nil)
    current_status.intake_status != intake_status || current_status.return_status != return_status || current_status.eip_status != eip_status
  end

  def mixpanel_routing_data
    {
      path: request.path,
      full_path: request.fullpath,
      controller_name: self.class.name.sub("Controller", ""),
      controller_action: "#{self.class.name}##{action_name}",
      controller_action_name: action_name,
    }
  end

  def intakes_for_ticket
    @intakes_for_ticket ||= Intake.where(intake_ticket_id: json_payload[:ticket_id])
  end

  def has_valid_intake_id?
    json_payload[:external_id].include?("intake-")
  end

  def incoming_ticket_statuses
    # If a webhook event has an EIP status, skip reporting other statuses.
    if json_payload[:eip_return_status].present?
      { eip_status: json_payload[:eip_return_status] }
    else
      {
        intake_status: json_payload[:digital_intake_status],
        return_status: json_payload[:return_status],
      }
    end
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
