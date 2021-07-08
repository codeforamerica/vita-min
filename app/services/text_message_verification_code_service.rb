class TextMessageVerificationCodeService
  SERVICE_TYPES = [:ctc, :gyr].freeze
  def initialize(phone_number:, locale: :en, visitor_id:, client_id: nil, service_type: :gyr)
    @service_type = service_type.to_sym
    raise(ArgumentError, "Unsupported service_type: #{service_type}") unless SERVICE_TYPES.include? @service_type

    @service_type = service_type.to_sym
    @phone_number = phone_number
    @locale = locale
    @visitor_id = visitor_id
    @client_id = client_id
  end

  def request_code
    create_code
  end

  private

  def create_code
    verification_code, access_token = generate_verification_code
    service_name = @service_type.to_s.match?(/ctc/) ? "GetCTC" : "GetYourRefund"
    twilio_response = TwilioService.send_text_message(
      to: @phone_number,
      body: I18n.t("verification_code_sms.with_code", service_name: service_name, locale: @locale, verification_code: verification_code).strip
    )
    VerificationTextMessage.create!(
      text_message_access_token: access_token,
      visitor_id: @visitor_id,
      twilio_sid: twilio_response&.sid
    )
  end

  def generate_verification_code
    existing_tokens = TextMessageAccessToken.where(sms_phone_number: @phone_number, token_type: "verification_code")
    existing_tokens.order(created_at: :asc).limit(existing_tokens.count - 4).delete_all if existing_tokens.count > 4
    DatadogApi.increment("client_logins.verification_codes.text_message.created")
    raw_verification_code, hashed_verification_code = VerificationCodeService.generate(@phone_number)
    [raw_verification_code, TextMessageAccessToken.create!(
      sms_phone_number: @phone_number,
      token_type: "verification_code",
      token: Devise.token_generator.digest(TextMessageAccessToken, :token, hashed_verification_code),
      client_id: @client_id
    )]
  end

  def self.request_code(*args)
    new(*args).request_code
  end
end