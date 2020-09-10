class TwilioWebhooksController < ApplicationController
  skip_before_action :redirect_to_getyourrefund
  skip_before_action :set_visitor_id
  skip_before_action :set_source
  skip_before_action :set_referrer
  skip_before_action :set_utm_state
  skip_before_action :set_sentry_context
  skip_before_action :check_maintenance_mode
  skip_before_action :verify_authenticity_token
  skip_after_action :track_page_view
  before_action :validate_twilio_request

  def update_outgoing_text_message
    OutgoingTextMessage.find(params[:id]).update(twilio_status: params["MessageStatus"])
    head :ok
  end

  def create_incoming_text_message
    phone_number = Phonelib.parse(params["From"]).sanitized
    client = Client.where(phone_number: phone_number).or(Client.where(sms_phone_number: phone_number)).first
    unless client.present?
      client = Client.create!(phone_number: phone_number, sms_phone_number: phone_number)
    end

    IncomingTextMessage.create!(
      body: params["Body"],
      received_at: DateTime.now,
      from_phone_number: phone_number,
      client: client,
    )
    head :ok
  end

  private

  def validate_twilio_request
    return head 403 unless TwilioService.valid_request?(request)
  end
end