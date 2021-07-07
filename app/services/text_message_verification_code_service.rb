class TextMessageVerificationCodeService
  VERIFICATION_TYPES = [:ctc_intake, :gyr_login]
  def initialize(phone_number: , locale: :en, visitor_id: , client_id: nil, verification_type: :gyr_login)
    raise(ArgumentError, "Unsupported verification type: #{verification_type}") unless VERIFICATION_TYPES.include? verification_type

    @verification_type = verification_type.to_sym
    @phone_number = phone_number
    @locale = locale
    @visitor_id = visitor_id
    @client_id = client_id
  end

  def request_code
    can_send_code? ? create_code : send_no_match_message
  end

  private

  def can_send_code?
    case @verification_type
    when :ctc_intake
      true
    when :gyr_login
      ClientLoginsService.accessible_intakes.where(phone_number: @phone_number).or(
          ClientLoginsService.accessible_intakes.where(sms_phone_number: @phone_number)).exists?
    end
  end

  def create_code
    verification_code, access_token = generate_verification_code
    VerificationTextMessage.create!(text_message_access_token: access_token, visitor_id: @visitor_id)
    service_name = @verification_type.to_s.match?(/ctc/) ? "GetCTC" : "GetYourRefund"
    TwilioService.send_text_message(
      to: @phone_number,
      body: I18n.t("verification_code_sms.with_code", service_name: service_name, locale: @locale, verification_code: verification_code).strip
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

  def send_no_match_message
    home_url = Rails.application.routes.url_helpers.root_url(locale: @locale)
    TwilioService.send_text_message(
      to: @phone_number,
      body: I18n.t("verification_code_sms.no_match", locale: @locale, home_url: home_url)
    )
  end

  def self.request_code(*args)
    new(*args).request_code
  end
end