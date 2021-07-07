class EmailVerificationCodeService
  VERIFICATION_TYPES = [:ctc_intake, :gyr_login]
  def initialize(email_address: , locale: :en, visitor_id: , client_id: nil, verification_type: :gyr_login)
    raise(ArgumentError, "Unsupported verification type: #{verification_type}") unless VERIFICATION_TYPES.include? verification_type

    @verification_type = verification_type.to_sym
    @email_address = email_address
    @locale = locale
    @visitor_id = visitor_id
    @client_id = client_id
  end

  def request_code
    can_send_code? ? send_verification_code : send_no_match_message
  end

  private

  def can_send_code?
    case @verification_type
    when :ctc_intake
      true
    when :gyr_login
      ClientLoginsService.accessible_intakes.where(email_address: @email_address).or(
      ClientLoginsService.accessible_intakes.where(spouse_email_address: @email_address)).exists?
    end
  end

  # sends an email synchronously using deliver_now so that we can store the mailgun ID,
  # so best to send this from a background job.
  def send_verification_code
    verification_code, access_token = generate_verification_code
    mailer_response = VerificationCodeMailer.with(
      to: @email_address,
      verification_code: verification_code,
      locale: @locale,
      verification_type: @verification_type
    ).with_code.deliver_now
    VerificationEmail.create!(
      email_access_token: access_token,
      visitor_id: @visitor_id,
      mailgun_id: mailer_response.message_id
    )
  end

  def generate_verification_code
    existing_tokens = EmailAccessToken.where(email_address: @email_address, token_type: "verification_code")
    existing_tokens.order(created_at: :asc).limit(existing_tokens.count - 4).delete_all if existing_tokens.count > 4
    raw_verification_code, hashed_verification_code = VerificationCodeService.generate(@email_address)
    DatadogApi.increment("client_logins.verification_codes.email.created")
    [raw_verification_code, EmailAccessToken.create!(
      email_address: @email_address,
      token_type: "verification_code",
      token: Devise.token_generator.digest(EmailAccessToken, :token, hashed_verification_code),
      client_id: @client_id
    )]
  end

  def send_no_match_message
    VerificationCodeMailer.with(
      to: @email_address,
      locale: @locale,
    ).no_match_found.deliver_now
  end

  def self.request_code(*args)
    new(*args).request_code
  end
end