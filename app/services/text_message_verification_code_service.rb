class TextMessageVerificationCodeService
  def initialize(phone_number:, locale: :en, visitor_id:, client_id: nil, service_type:)
    @service_data = MultiTenantService.new(service_type)
    @phone_number = phone_number
    @locale = locale
    @visitor_id = visitor_id
    @client_id = client_id
  end

  def request_code
    verification_code, access_token = TextMessageAccessToken.generate!(sms_phone_number: @phone_number, client_id: @client_id)
    twilio_response = TwilioService.send_text_message(
      to: @phone_number,
      body: I18n.t("verification_code_sms.with_code",
                   service_name: @service_data.service_name,
                   locale: @locale,
                   verification_code: verification_code
      ).strip
    )
    VerificationTextMessage.create!(
      text_message_access_token: access_token,
      visitor_id: @visitor_id,
      twilio_sid: twilio_response&.sid
    )
  end

  private


  def self.request_code(*args)
    new(*args).request_code
  end
end