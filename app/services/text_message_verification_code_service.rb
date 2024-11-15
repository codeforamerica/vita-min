class TextMessageVerificationCodeService
  include Rails.application.routes.url_helpers

  def initialize(phone_number:, locale: :en, visitor_id:, client_id: nil, service_type:)
    @service_data = MultiTenantService.new(service_type)
    @phone_number = phone_number
    @locale = locale
    @visitor_id = visitor_id
    @client_id = client_id
  end

  def request_code
    verification_code, access_token = TextMessageAccessToken.generate!(sms_phone_number: @phone_number, client_id: @client_id)
    outgoing_message_status = OutgoingMessageStatus.find_or_create_by!(message_type: :sms, parent: access_token)
    twilio_response = TwilioService.new(@service_data.service_type).send_text_message(
      to: @phone_number,
      body: I18n.t("verification_code_sms.with_code",
                   service_name: @service_data.service_name,
                   locale: @locale,
                   verification_code: verification_code
      ).strip,
      status_callback: twilio_update_status_url(outgoing_message_status.id, locale: nil),
    )
    VerificationTextMessage.create!(
      text_message_access_token: access_token,
      visitor_id: @visitor_id,
      twilio_sid: twilio_response&.sid
    )
    outgoing_message_status.update(message_id: twilio_response&.sid) if twilio_response&.sid.present?
  end

  private


  def self.request_code(**args)
    new(**args).request_code
  end
end
